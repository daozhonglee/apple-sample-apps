/*
See the License.txt file for this sample’s licensing information.
*/

import Photos
import os.log

/// 照片资源模型
/// 为 PHAsset 提供了一个更易用的包装，添加了标识符和收藏等功能
struct PhotoAsset: Identifiable {
    /// 唯一标识符，用于区分不同的照片资源
    var id: String { identifier }
    /// 资源的本地标识符
    var identifier: String = UUID().uuidString
    /// 在集合中的索引位置
    var index: Int?
    /// 对应的 Photos 框架的资产对象
    var phAsset: PHAsset?
    
    /// 媒体类型的类型别名
    typealias MediaType = PHAssetMediaType
    
    /// 是否被收藏
    var isFavorite: Bool {
        phAsset?.isFavorite ?? false
    }
    
    /// 媒体类型（照片、视频等）
    var mediaType: MediaType {
        phAsset?.mediaType ?? .unknown
    }
    
    /// 用于无障碍功能的标签文本
    var accessibilityLabel: String {
        "Photo\(isFavorite ? ", Favorite" : "")"
    }

    init(phAsset: PHAsset, index: Int?) {
        self.phAsset = phAsset
        self.index = index
        self.identifier = phAsset.localIdentifier
    }
    
    init(identifier: String) {
        self.identifier = identifier
        let fetchedAssets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        self.phAsset = fetchedAssets.firstObject
    }
    
    /// 设置照片的收藏状态
    /// - Parameter isFavorite: 是否收藏
    func setIsFavorite(_ isFavorite: Bool) async {
        guard let phAsset = phAsset else { return }
        Task {
            do {
                try await PHPhotoLibrary.shared().performChanges {
                    let request = PHAssetChangeRequest(for: phAsset)
                    request.isFavorite = isFavorite
                }
            } catch (let error) {
                logger.error("Failed to change isFavorite: \(error.localizedDescription)")
            }
        }
    }
    
    /// 从相册中删除该照片
    func delete() async {
        guard let phAsset = phAsset else { return }
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets([phAsset] as NSArray)
            }
            logger.debug("PhotoAsset asset deleted: \(index ?? -1)")
        } catch (let error) {
            logger.error("Failed to delete photo: \(error.localizedDescription)")
        }
    }
}

extension PhotoAsset: Equatable {
    /// 实现相等性比较
    /// 同时比较标识符和收藏状态
    static func ==(lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
        (lhs.identifier == rhs.identifier) && (lhs.isFavorite == rhs.isFavorite)
    }
}

extension PhotoAsset: Hashable {
    /// 实现哈希函数
    /// 仅使用标识符进行哈希，因为它是唯一的
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

/// 使 PHObject 符合 Identifiable 协议
/// 便于在 SwiftUI 列表和集合视图中使用
extension PHObject: Identifiable {
    /// 使用 localIdentifier 作为唯一标识符
    public var id: String { localIdentifier }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "PhotoAsset")

