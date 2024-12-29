/*
See the License.txt file for this sample’s licensing information.
*/

// 引入所需的框架
import AVFoundation
import CoreImage
import UIKit
import os.log

// Camera: 基础相机类
// 负责相机的基本功能：初始化、配置、捕获等
class Camera: NSObject {
    // 相机会话，管理输入输出数据流
    private let captureSession = AVCaptureSession()
    // 会话配置状态标志
    private var isCaptureSessionConfigured = false
    // 设备输入，用于接收相机数据
    private var deviceInput: AVCaptureDeviceInput?
    // 照片输出，用于捕获静态图像
    private var photoOutput: AVCapturePhotoOutput?
    // 视频输出，用于捕获视频流
    private var videoOutput: AVCaptureVideoDataOutput?
    // 会话队列，用于异步处理相机操作
    private var sessionQueue: DispatchQueue!
    
    // 获取所有可用的相机设备
    private var allCaptureDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera, .builtInUltraWideCamera], mediaType: .video, position: .unspecified).devices
    }
    
    // 获取前置相机设备
    private var frontCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .front }
    }
    
    // 获取后置相机设备
    private var backCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .back }
    }
    
    // 根据平台获取可用的相机设备
    private var captureDevices: [AVCaptureDevice] {
        var devices = [AVCaptureDevice]()
        #if os(macOS) || (os(iOS) && targetEnvironment(macCatalyst))
        devices += allCaptureDevices
        #else
        if let frontDevice = frontCaptureDevices.first {
            devices += [frontDevice]
        }
        if let backDevice = backCaptureDevices.first {
            devices += [backDevice]
        }
        #endif
        return devices
    }
    
    // 获取当前可用的相机设备
    private var availableCaptureDevices: [AVCaptureDevice] {
        captureDevices
            .filter( { $0.isConnected } )
            .filter( { !$0.isSuspended } )
    }
    
    // 当前使用的相机设备
    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            logger.debug("Using capture device: \(captureDevice.localizedName)")
            updateSessionForCaptureDevice(captureDevice)
        }
    }
    
    // 相机运行状态
    var isRunning: Bool {
        captureSession.isRunning
    }
    
    // 是否使用前置相机
    var isUsingFrontCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return frontCaptureDevices.contains(captureDevice)
    }
    
    // 是否使用后置相机
    var isUsingBackCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return backCaptureDevices.contains(captureDevice)
    }

    // 照片流处理回调
    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?
    
    // 预览流处理回调
    private var addToPreviewStream: ((CIImage) -> Void)?
    
    // 预览暂停状态
    var isPreviewPaused = false
    
    // 预览图像流
    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
                if (!self.isPreviewPaused) {
                    continuation.yield(ciImage)
                }
            }
        }
    }()
    
    // 照片流
    lazy var photoStream: AsyncStream<AVCapturePhoto> = {
        AsyncStream { continuation in
            addToPhotoStream = { photo in
                continuation.yield(photo)
            }
        }
    }()
    
    // 机器学习代理
    var mlDelegate: MLDelegate?
    // 预览图像尺寸
    var previewImageSize: CGSize = .zero

    // 初始化相机
    override init() {
        super.init()
        initialize()
    }
    
    // 初始化基本设置
    private func initialize() {
        // 创建会话队列
        sessionQueue = DispatchQueue(label: "session queue")
        
        // 开始监听设备方向变化        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(updateForDeviceOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // 配置并启动捕获会话
    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
        // 标记配置是否成功
        var success = false
        
        // 开始配置会话
        self.captureSession.beginConfiguration()
        
        // 确保在函数退出时提交配置并调用完成处理器
        defer {
            self.captureSession.commitConfiguration()
            completionHandler(success)
        }
        
        // 初始化设备输入和输出
        guard
            let captureDevice = captureDevice,
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        else {
            logger.error("Failed to obtain video input.")
            return
        }
        
        // 创建照片输出对象
        let photoOutput = AVCapturePhotoOutput()
        
        // 设置会话的预设质量                    
        captureSession.sessionPreset = AVCaptureSession.Preset.photo

        // 创建视频输出对象和代理队列
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutputQueue"))
        
        // 验证是否可以添加输入输出
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
        
        // 添加输入和输出到会话
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        
        // 存储输入输出引用
        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput
        
        // 配置照片输出质量
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        // 更新视频输出连接
        updateVideoOutputConnection()
        
        // 标记会话已配置
        isCaptureSessionConfigured = true
        
        // 设置配置成功
        success = true
    }
    
    // 异步检查相机授权状态
    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            logger.debug("Camera access authorized.")
            return true
        case .notDetermined:
            logger.debug("Camera access not determined.")
            sessionQueue.suspend()
            let status = await AVCaptureDevice.requestAccess(for: .video)
            sessionQueue.resume()
            return status
        case .denied:
            logger.debug("Camera access denied.")
            return false
        case .restricted:
            logger.debug("Camera library access restricted.")
            return false
        @unknown default:
            return false
        }
    }
    
    // 为指定设备创建输入
    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let error {
            logger.error("Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }
    
    // 更新会话的捕获设备
    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        
        if let deviceInput = deviceInputFor(device: captureDevice) {
            if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        }
        
        updateVideoOutputConnection()
    }
    
    // 更新视频输出连接设置
    private func updateVideoOutputConnection() {
        // 获取视频输出连接
        if let videoOutput = videoOutput, let videoOutputConnection = videoOutput.connection(with: .video) {
            // 如果支持视频镜像，则根据是否使用前置相机设置镜像
            if videoOutputConnection.isVideoMirroringSupported {
                videoOutputConnection.isVideoMirrored = isUsingFrontCaptureDevice
            }
        }
    }
    
    // 开始相机会话
    func start() async {
        // 检查相机授权
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
        
        sessionQueue.async { [self] in
            if captureDevice == nil {
                captureDevice = availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
            }

            self.configureCaptureSession { success in
                guard success else { return }
                self.captureSession.startRunning()
            }
        }
    }
    
    // 停止相机会话
    func stop() {
        // 检查会话是否已配置
        guard isCaptureSessionConfigured else { return }
        
        // 如果会话正在运行，则停止它
        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    // 切换相机设备（前后摄像头）
    func switchCaptureDevice() {
        // 在会话队列中异步执行
        sessionQueue.async {
            // 获取可用的捕获设备
            let availableCaptureDevices = self.availableCaptureDevices
            // 如果当前有活动设备，找到它的索引并切换到下一个设备
            if let captureDevice = self.captureDevice, let index = availableCaptureDevices.firstIndex(of: captureDevice) {
                let nextIndex = (index + 1) % availableCaptureDevices.count
                self.captureDevice = availableCaptureDevices[nextIndex]
            } else {
                // 如果没有活动设备，使用默认视频设备
                self.captureDevice = AVCaptureDevice.default(for: .video)
            }
        }
    }

    // 获取当前设备方向
    private var deviceOrientation: UIDeviceOrientation {
        // 获取当前设备方向
        var orientation = UIDevice.current.orientation
        // 如果方向未知，则使用屏幕方向
        if orientation == UIDeviceOrientation.unknown {
            orientation = UIScreen.main.orientation
        }
        return orientation
    }
    
    // 设备方向更新回调
    @objc
    func updateForDeviceOrientation() {
        //TODO: Figure out if we need this for anything.
    }
    
    // 根据设备方向获取视频方向
    private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
        // 根据设备方向返回对应的视频方向
        switch deviceOrientation {
        case .portrait: return AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft: return AVCaptureVideoOrientation.landscapeRight
        case .landscapeRight: return AVCaptureVideoOrientation.landscapeLeft
        default: return nil
        }
    }
    
    // 拍照功能
    func takePhoto() {
        guard let photoOutput = self.photoOutput else { return }
        
        sessionQueue.async {
            // 创建照片设置
            var photoSettings = AVCapturePhotoSettings()

            // 检查并使用HEVC编码（如果可用）
            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            // 配置闪光灯
            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? .auto : .off
            
            // 配置照片质量和分辨率
            photoSettings.isHighResolutionPhotoEnabled = true
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            photoSettings.photoQualityPrioritization = .balanced
            
            // 设置照片方向
            if let photoOutputVideoConnection = photoOutput.connection(with: .video) {
                if photoOutputVideoConnection.isVideoOrientationSupported,
                    let videoOrientation = self.videoOrientationFor(self.deviceOrientation) {
                    photoOutputVideoConnection.videoOrientation = videoOrientation
                }
            }
            
            // 捕获照片
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}

// 照片捕获代理扩展
extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            logger.error("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        addToPhotoStream?(photo)
    }
}

// 视频数据输出代理扩展
extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    // 处理捕获的视频帧
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 从采样缓冲区获取像素缓冲区
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        
        // 设置视频方向
        if connection.isVideoOrientationSupported,
           let videoOrientation = videoOrientationFor(deviceOrientation) {
            connection.videoOrientation = videoOrientation
        }

        // 创建 CIImage 并发送到预览流
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        addToPreviewStream?(ciImage)
        previewImageSize = ciImage.extent.size
        
        // 如果有ML代理，收集观察数据
        guard let delegate = mlDelegate else { return }

        // 异步收集观察数据
        Task {
            await delegate.gatherObservations(pixelBuffer: pixelBuffer)
        }
    }
}

// 屏幕方向扩展
fileprivate extension UIScreen {
    // 获取设备方向
    var orientation: UIDeviceOrientation {
        // 获取坐标转换点
        let point = coordinateSpace.convert(CGPoint.zero, to: fixedCoordinateSpace)
        // 根据转换点确定方向
        if point == CGPoint.zero {
            return .portrait // 竖直方向
        } else if point.x != 0 && point.y != 0 {
            return .portraitUpsideDown // 倒置
        } else if point.x == 0 && point.y != 0 {
            return .landscapeRight // 横向右
        } else if point.x != 0 && point.y == 0 {
            return .landscapeLeft // 横向左
        } else {
            return .unknown // 未知方向
        }
    }
}

// 创建日志记录器
fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "Camera")

// 机器学习代理协议
protocol MLDelegate: AnyObject {
    // 更新机器学习模型
    func updateMLModel(with model: NSObject)
    // 收集观察数据
    func gatherObservations(pixelBuffer: CVImageBuffer) async
}
