/*
See the License.txt file for this sample’s licensing information.
*/

import UIKit
import Photos
import SwiftUI
import os.log

/// 图片缓存管理器，使用 actor 确保线程安全
/// 负责管理照片资源的加载和缓存
actor CachedImageManager {
    
    // Photos框架的缓存图片管理器
    private let imageManager = PHCachingImageManager()
    
    // 图片内容填充模式
    private var imageContentMode = PHImageContentMode.aspectFit
    
    /// 定义可能出现的错误类型
    enum CachedImageManagerError: LocalizedError {
        case error(Error)      // 一般错误
        case cancelled        // 请求被取消
        case failed          // 请求失败
    }
    
    // 已缓存图片的标识符字典
    private var cachedAssetIdentifiers = [String : Bool]()
    
    /// 图片请求选项配置
    private lazy var requestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic  // 优先返回低质量图片，随后更新高质量版本
        return options
    }()
    
    /// 初始化缓存管理器
    /// 禁用高质量图片缓存以节省内存
    init() {
        imageManager.allowsCachingHighQualityImages = false
    }
    
    /// 获取当前缓存的图片数量
    var cachedImageCount: Int {
        cachedAssetIdentifiers.keys.count
    }
    
    /// 开始缓存指定资源的图片
    /// - Parameters:
    ///   - assets: 需要缓存的照片资源数组
    ///   - targetSize: 目标图片尺寸
    func startCaching(for assets: [PhotoAsset], targetSize: CGSize) {
        let phAssets = assets.compactMap { $0.phAsset }
        phAssets.forEach {
            cachedAssetIdentifiers[$0.localIdentifier] = true
        }
        imageManager.startCachingImages(for: phAssets, targetSize: targetSize, contentMode: imageContentMode, options: requestOptions)
    }

    /// 停止缓存指定资源的图片
    /// - Parameters:
    ///   - assets: 需要停止缓存的照片资源数组
    ///   - targetSize: 目标图片尺寸
    func stopCaching(for assets: [PhotoAsset], targetSize: CGSize) {
        let phAssets = assets.compactMap { $0.phAsset }
        phAssets.forEach {
            cachedAssetIdentifiers.removeValue(forKey: $0.localIdentifier)
        }
        imageManager.stopCachingImages(for: phAssets, targetSize: targetSize, contentMode: imageContentMode, options: requestOptions)
    }
    
    /// 停止所有图片的缓存
    func stopCaching() {
        imageManager.stopCachingImagesForAllAssets()
    }
    
    /// 请求加载照片资源的图片
    /// - Parameters:
    ///   - asset: 照片资源
    ///   - targetSize: 目标图片尺寸
    ///   - completion: 完成回调，返回 SwiftUI.Image 和质量标志
    /// - Returns: 请求ID，可用于取消请求
    @discardableResult
    func requestImage(for asset: PhotoAsset, targetSize: CGSize, completion: @escaping ((image: Image?, isLowerQuality: Bool)?) -> Void) -> PHImageRequestID? {
        guard let phAsset = asset.phAsset else {
            completion(nil)
            return nil
        }
        
        let requestID = imageManager.requestImage(for: phAsset, targetSize: targetSize, contentMode: imageContentMode, options: requestOptions) { image, info in
            if let error = info?[PHImageErrorKey] as? Error {
                logger.error("CachedImageManager requestImage error: \(error.localizedDescription)")
                completion(nil)
            } else if let cancelled = (info?[PHImageCancelledKey] as? NSNumber)?.boolValue, cancelled {
                logger.debug("CachedImageManager request canceled")
                completion(nil)
            } else if let image = image {
                let isLowerQualityImage = (info?[PHImageResultIsDegradedKey] as? NSNumber)?.boolValue ?? false
                let result = (image: Image(uiImage: image), isLowerQuality: isLowerQualityImage)
                completion(result)
            } else {
                completion(nil)
            }
        }
        return requestID
    }
    
    /// 取消指定ID的图片请求
    func cancelImageRequest(for requestID: PHImageRequestID) {
        imageManager.cancelImageRequest(requestID)
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "CachedImageManager")

