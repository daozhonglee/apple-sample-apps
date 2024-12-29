/*
See the License.txt file for this sample’s licensing information.
*/

import AVFoundation
import SwiftUI
import os.log

/// 相机应用的数据模型
/// 负责协调相机操作和照片管理
final class DataModel: ObservableObject {
    // 相机控制器实例
    let camera = Camera()
    // 照片集合管理器，默认使用系统相册
    let photoCollection = PhotoCollection(smartAlbum: .smartAlbumUserLibrary)
    
    // 取景器预览图像
    @Published var viewfinderImage: Image?
    // 最近拍摄照片的缩略图
    @Published var thumbnailImage: Image?
    
    // 标记照片是否已加载
    var isPhotosLoaded = false
    
    init() {
        // 启动两个异步任务处理相机预览和照片捕获
        Task {
            await handleCameraPreviews()
        }
        
        Task {
            await handleCameraPhotos()
        }
    }
    
    /// 处理相机预览流
    /// 将相机输出的每一帧转换为 SwiftUI Image 并更新到 UI
    func handleCameraPreviews() async {
        // 使用流的 map(_:) 函数将每个元素 — $0 — 使用 CIImage 的图像属性扩展转换为 Image 实例。这会将 CIImage 实例流转换为 Image 实例流。
        let imageStream = camera.previewStream
            .map { $0.image }

        for await image in imageStream {
            //这里使用@MainActor标记，确保在主线程上更新UI， 原因是iOS/macOS 所有 UI 更新必须在主线程执行，违反此规则可能导致崩溃或未定义行为
            Task { @MainActor in // // 创建主线程任务
                viewfinderImage = image
            }
        }
    }
    
    /// 处理拍摄的照片
    /// 保存照片并更新缩略图
    //相机 photoStream 中的每个 AVCapturePhoto 元素可能包含多个不同分辨率的图像，以及有关图像的其他元数据，例如图像的大小以及捕获图像的日期和时间。
    //必须解压它才能获取所需的图像和元数据。
    func handleCameraPhotos() async {
        let unpackedPhotoStream = camera.photoStream
            .compactMap { self.unpackPhoto($0) }
        
        for await photoData in unpackedPhotoStream {
            Task { @MainActor in
                thumbnailImage = photoData.thumbnailImage
            }
            savePhoto(imageData: photoData.imageData)
        }
    }
    
    /// 解包并处理捕获的照片数据
    /// 提取预览图像和元数据
    private func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoData? {
        // 获取照片的原始数据
        guard let imageData = photo.fileDataRepresentation() else { return nil }

        // 获取预览图像和方向信息
        guard let previewCGImage = photo.previewCGImageRepresentation(),
           // 从元数据中获取图片方向信息
           let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
           // 将方向信息转换为 CGImagePropertyOrientation
           let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation) else { return nil }
        
        // 创建 SwiftUI Image，设置正确的方向
        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)
        
        // 获取照片的原始尺寸
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        
        // 获取预览图的尺寸
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))
        
        // 创建并返回包含所有照片信息的数据结构
        return PhotoData(thumbnailImage: thumbnailImage, 
                        thumbnailSize: thumbnailSize, 
                        imageData: imageData, 
                        imageSize: imageSize)
    }
    
    /// 保存拍摄的照片到相册
    /// - Parameter imageData: 照片原始数据
    func savePhoto(imageData: Data) {
        Task {
            do {
                try await photoCollection.addImage(imageData)
                logger.debug("Added image data to photo collection.")
            } catch let error {
                logger.error("Failed to add image to photo collection: \(error.localizedDescription)")
            }
        }
    }
    
    /// 加载照片库中的照片
    /// 首先检查权限，然后加载照片集合
    func loadPhotos() async {
        // 避免重复加载
        guard !isPhotosLoaded else { return }
        
        // 检查相册访问权限
        let authorized = await PhotoLibrary.checkAuthorization()
        guard authorized else {
            logger.error("Photo library access was not authorized.")
            return
        }
        
        Task {
            do {
                // 加载相册内容
                try await self.photoCollection.load()
                // 加载第一张照片作为缩略图
                await self.loadThumbnail()
            } catch let error {
                // 处理加载失败的情况
                logger.error("Failed to load photo collection: \(error.localizedDescription)")
            }
            // 标记照片已加载完成
            self.isPhotosLoaded = true
        }
    }
    
    /// 加载第一张照片的缩略图
    /// 用于显示在相机界面底部的相册按钮上
    func loadThumbnail() async {
        guard let asset = photoCollection.photoAssets.first else { return }
        await photoCollection.cache.requestImage(for: asset, targetSize: CGSize(width: 256, height: 256)) { result in
            if let result = result {
                Task { @MainActor in
                    self.thumbnailImage = result.image
                }
            }
        }
    }
}

/// 照片数据结构
/// 用于存储照片的预览图和原始数据
fileprivate struct PhotoData {
    // 照片的缩略图
    var thumbnailImage: Image
    // 缩略图尺寸
    var thumbnailSize: (width: Int, height: Int)
    // 原始照片数据
    var imageData: Data
    // 原始照片尺寸
    var imageSize: (width: Int, height: Int)
}

/// CIImage扩展
/// 提供将CIImage转换为SwiftUI.Image的功能
fileprivate extension CIImage {
    /// 将CIImage转换为SwiftUI.Image
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

/// Image.Orientation扩展
/// 提供从CGImagePropertyOrientation转换为Image.Orientation的功能
fileprivate extension Image.Orientation {
    /// 根据CGImage的方向创建Image的方向
    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "DataModel")
