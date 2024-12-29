/*
See the License.txt file for this sample’s licensing information.
*/

import AVFoundation
import CoreImage
import UIKit
import os.log

/// 相机核心类，负责管理相机的所有功能
/// 包括：相机的初始化、配置、拍照、预览等功能
/// 继承自NSObject并实现了拍照和视频输出的代理协议
class Camera: NSObject {
    // AVCaptureSession: 用于协调相机输入和输出之间的数据流
    // 它是整个相机系统的核心，管理着从相机设备捕获数据到输出的整个过程
    private let captureSession = AVCaptureSession()
    
    // 标记captureSession是否已经完成配置
    private var isCaptureSessionConfigured = false
    
    // AVCaptureDeviceInput: 表示相机设备的输入源
    // 可以是前置摄像头或后置摄像头
    private var deviceInput: AVCaptureDeviceInput?
    
    // AVCapturePhotoOutput: 用于处理静态照片的捕获
    // 提供了高质量的照片捕获功能
    private var photoOutput: AVCapturePhotoOutput?
    
    // AVCaptureVideoDataOutput: 用于处理视频帧
    // 主要用于相机预览功能
    private var videoOutput: AVCaptureVideoDataOutput?
    
    // 专门的串行队列，用于处理所有相机相关的操作
    // 避免在主线程进行耗时的相机操作
    private var sessionQueue: DispatchQueue!
    
    /// 获取系统所有可用的相机设备
    /// 包括：原深感摄像头、双摄像头、广角摄像头等
    private var allCaptureDevices: [AVCaptureDevice] {
        // DiscoverySession用于发现系统中可用的捕获设备
        AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTrueDepthCamera,   // 原深感相机，支持面部识别
                .builtInDualCamera,        // 双摄像头，支持景深效果
                .builtInDualWideCamera,    // 双广角摄像头
                .builtInWideAngleCamera,   // 广角摄像头
                .builtInDualWideCamera     // 双广角摄像头（重复，可能是遗留代码）
            ],
            mediaType: .video,             // 指定设备类型为视频
            position: .unspecified         // 不指定位置，获取所有位置的设备
        ).devices
    }
    
    // 获取前置摄像头设备
    private var frontCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices.filter { $0.position == .front }
    }
    
    // 获取后置摄像头设备
    private var backCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices.filter { $0.position == .back }
    }
    
    /// 根据操作系统和运行环境获取可用的相机设备
    /// 在iOS设备上，只返回第一个前置和后置摄像头
    /// 在macOS或Catalyst环境下，返回所有可用设备
    private var captureDevices: [AVCaptureDevice] {
        var devices = [AVCaptureDevice]()
        #if os(macOS) || (os(iOS) && targetEnvironment(macCatalyst))
        devices += allCaptureDevices
        #else
        if let backDevice = backCaptureDevices.first {
            devices += [backDevice]
        }
        if let frontDevice = frontCaptureDevices.first {
            devices += [frontDevice]
        }
        #endif
        return devices
    }
    
    /// 获取当前实际可用的相机设备
    /// 过滤掉未连接或已暂停的设备
    private var availableCaptureDevices: [AVCaptureDevice] {
        captureDevices
            .filter( { $0.isConnected } )  // 确保设备是连接状态
            .filter( { !$0.isSuspended } ) // 确保设备未被暂停
    }
    
    /// 当前使用的相机设备
    /// 当设备变化时，会自动更新相机会话配置
    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            logger.debug("Using capture device: \(captureDevice.localizedName)")
            sessionQueue.async {
                self.updateSessionForCaptureDevice(captureDevice)
            }
        }
    }
    
    /// 相机会话是否正在运行
    var isRunning: Bool {
        captureSession.isRunning
    }
    
    /// 当前是否正在使用前置摄像头
    var isUsingFrontCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return frontCaptureDevices.contains(captureDevice)
    }
    
    /// 当前是否正在使用后置摄像头
    var isUsingBackCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return backCaptureDevices.contains(captureDevice)
    }

    /// 用于向外传递拍摄的照片回调闭包
    /// 当照片拍摄完成时会调用此闭包
    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?
    
    /// 用于向外传递预览画面的回调闭包
    /// 每一帧新的预览画面都会调用此闭包
    private var addToPreviewStream: ((CIImage) -> Void)?
    
    /// 是否暂停预览
    /// 当切换到其他界面时可以暂停预览以节省资源
    var isPreviewPaused = false
    
    /// 预览流，使用Swift新的并发特性AsyncStream
    /// 将实时预览帧以异步流的形式向外提供
    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
                if !self.isPreviewPaused {
                    continuation.yield(ciImage)
                }
            }
        }
    }()
    
    /// 照片流，使用Swift新的并发特性AsyncStream
    /// 当拍照完成时，将照片数据以异步流的形式向外提供
    lazy var photoStream: AsyncStream<AVCapturePhoto> = {
        AsyncStream { continuation in
            addToPhotoStream = { photo in
                continuation.yield(photo)
            }
        }
    }()
        
    override init() {
        super.init()
        initialize()
    }
    
    /// 初始化相机
    /// 创建会话队列并设置初始相机设备
    /// 注册设备方向变化通知
    private func initialize() {
        // 创建专门的串行队列处理相机操作
        sessionQueue = DispatchQueue(label: "session queue")
        
        // 设置初始相机设备，优先使用可用设备列表中的第一个，如果没有则使用默认视频设备
        captureDevice = availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
        
        // 开始监听设备方向变化
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(updateForDeviceOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // 配置相机会话,设置输入输出
    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
        
        var success = false
        
        // 开始配置
        self.captureSession.beginConfiguration()
        
        defer {
            // 确保在函数返回时提交配置
            self.captureSession.commitConfiguration()
            completionHandler(success)
        }
        
        // 配置相机输入设备
        guard
            let captureDevice = captureDevice,
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        else {
            logger.error("Failed to obtain video input.")
            return
        }
        
        // 配置照片输出
        let photoOutput = AVCapturePhotoOutput()
                        
        // 设置会话的预设质量
        captureSession.sessionPreset = AVCaptureSession.Preset.photo

        // 配置视频输出
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutputQueue"))
  
        guard captureSession.canAddInput(deviceInput) else {
            logger.error("Unable to add device input to capture session.")
            return
        }
        guard captureSession.canAddOutput(photoOutput) else {
            logger.error("Unable to add photo output to capture session.")
            return
        }
        guard captureSession.canAddOutput(videoOutput) else {
            logger.error("Unable to add video output to capture session.")
            return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        
        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput
        
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        updateVideoOutputConnection()
        
        isCaptureSessionConfigured = true
        
        success = true
    }
    
    /// 检查相机权限状态
    /// 返回一个布尔值表示是否有权限使用相机
    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:           // 已授权
            logger.debug("Camera access authorized.")
            return true
        case .notDetermined:        // 未确定，需要请求授权
            logger.debug("Camera access not determined.")
            sessionQueue.suspend()   // 暂停队列
            let status = await AVCaptureDevice.requestAccess(for: .video)  // 请求授权
            sessionQueue.resume()    // 恢复队列
            return status
        case .denied:              // 被用户拒绝
            logger.debug("Camera access denied.")
            return false
        case .restricted:          // 被系统限制（如家长控制）
            logger.debug("Camera library access restricted.")
            return false
        @unknown default:
            return false
        }
    }
    
    /// 为指定的相机设备创建输入源
    /// - Parameter device: 相机设备
    /// - Returns: 相机输入源或nil（如果创建失败）
    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let error {
            logger.error("Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 更新相机会话的设备配置
    /// 当切换相机时会调用此方法
    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        // 移除现有的所有输入
        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        
        // 添加新的设备输入
        if let deviceInput = deviceInputFor(device: captureDevice) {
            if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        }
        
        updateVideoOutputConnection()
    }
    
    /// 更新视频输出连接的配置
    /// 主要处理前置摄像头的镜像问题
    private func updateVideoOutputConnection() {
        if let videoOutput = videoOutput, let videoOutputConnection = videoOutput.connection(with: .video) {
            if videoOutputConnection.isVideoMirroringSupported {
                videoOutputConnection.isVideoMirrored = isUsingFrontCaptureDevice
            }
        }
    }
    
    /// 启动相机捕获会话
    /// 首先检查权限，然后配置并启动会话
    func start() async {
        let authorized = await checkAuthorization()
        guard authorized else {
            logger.error("Camera access was not authorized.")
            return
        }
        
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                sessionQueue.async { [self] in
                    self.captureSession.startRunning()
                }
            }
            return
        }
        
        // 这里为什么用 queue
        // 为什么使用 sessionQueue
        // AVFoundation 要求
        //  - 相机配置操作必须在后台线程执行
        //  -所有相机操作必须串行执行
        //  - startRunning() 和 stopRunning() 是耗时操作
        // 线程安全
        //  - 避免多线程并发访问相机
        //  - 防止资源竞争
        //  - 确保操作顺序
        sessionQueue.async { [self] in
            self.configureCaptureSession { success in /// 配置捕获会话
                guard success else { return }
                self.captureSession.startRunning() // // 启动捕获会话
            }
        }
    }
    
    /// 停止相机捕获会话
    func stop() {
        guard isCaptureSessionConfigured else { return }
        
        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    /// 切换前后摄像头
    func switchCaptureDevice() {
        if let captureDevice = captureDevice, let index = availableCaptureDevices.firstIndex(of: captureDevice) {
            let nextIndex = (index + 1) % availableCaptureDevices.count
            self.captureDevice = availableCaptureDevices[nextIndex]
        } else {
            self.captureDevice = AVCaptureDevice.default(for: .video)
        }
    }

    /// 获取当前设备的方向
    /// 如果无法获取当前方向，则使用屏幕方向作为备选
    private var deviceOrientation: UIDeviceOrientation {
        var orientation = UIDevice.current.orientation
        if (orientation == UIDeviceOrientation.unknown) {
            orientation = UIScreen.main.orientation
        }
        return orientation
    }
    
    /// 设备方向变化时的回调方法
    /// 当前为TODO状态，可能需要处理设备方向变化时的相关逻辑
    @objc
    func updateForDeviceOrientation() {
        //TODO: Figure out if we need this for anything.
    }
    
    /// 根据设备方向获取对应的视频方向
    /// 用于确保照片和视频预览的正确方向
    private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
        switch deviceOrientation {
        case .portrait: return AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft: return AVCaptureVideoOrientation.landscapeRight
        case .landscapeRight: return AVCaptureVideoOrientation.landscapeLeft
        default: return nil
        }
    }
    
    /// 拍照功能的核心实现
    /// 配置并执行拍照过程
    func takePhoto() {
        guard let photoOutput: AVCapturePhotoOutput = self.photoOutput else { return }
        
        sessionQueue.async {
            // 创建照片捕获设置
            var photoSettings = AVCapturePhotoSettings()

            // 检查是否支持HEVC(H.265)格式
            // HEVC提供更好的压缩率，但需要硬件支持
            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            // 配置闪光灯
            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? .auto : .off
            
            // 启用高分辨率照片捕获
            photoSettings.isHighResolutionPhotoEnabled = true
            
            // 设置预览图片的像素格式
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            
            // 设置照片质量优先级为平衡模式
            photoSettings.photoQualityPrioritization = .balanced
            
            // 设置照片方向
            if let photoOutputVideoConnection = photoOutput.connection(with: .video) {
                if photoOutputVideoConnection.isVideoOrientationSupported,
                    let videoOrientation = self.videoOrientationFor(self.deviceOrientation) {
                    photoOutputVideoConnection.videoOrientation = videoOrientation
                }
            }
            
            // 执行拍照操作
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension Camera: AVCapturePhotoCaptureDelegate {
    // 照片处理完成的回调
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            logger.error("Error capturing photo: \(error.localizedDescription)")
            return
        }
        addToPhotoStream?(photo)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate 
extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    // 处理视频帧数据
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        
        if connection.isVideoOrientationSupported,
           let videoOrientation = videoOrientationFor(deviceOrientation) {
            connection.videoOrientation = videoOrientation
        }

        addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
    }
}

fileprivate extension UIScreen {
    /// 获取屏幕的设备方向
    /// 通过坐标空间转换计算当前屏幕方向
    /// - Returns: UIDeviceOrientation 表示的设备方向
    var orientation: UIDeviceOrientation {
        // 将原点(0,0)从一个坐标空间转换到固定坐标空间
        let point = coordinateSpace.convert(CGPoint.zero, to: fixedCoordinateSpace)
        
        // 根据转换后的点的坐标判断设备方向
        if point == CGPoint.zero {
            return .portrait           // 正常竖屏
        } else if point.x != 0 && point.y != 0 {
            return .portraitUpsideDown // 倒置竖屏
        } else if point.x == 0 && point.y != 0 {
            return .landscapeRight     // 右横屏
        } else if point.x != 0 && point.y == 0 {
            return .landscapeLeft      // 左横屏
        } else {
            return .unknown           // 未知方向
        }
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "Camera")

