/*
See the License.txt file for this sample’s licensing information.
*/

import Photos

/// 照片资源集合类
/// 实现了 RandomAccessCollection 协议，支持随机访问和迭代
/// 提供照片资源的缓存和管理功能
class PhotoAssetCollection: RandomAccessCollection {
    // Photos框架的查询结果，包含实际的照片资产
    private(set) var fetchResult: PHFetchResult<PHAsset>
    // 用于遍历集合的当前索引
    private var iteratorIndex: Int = 0
    
    // 照片资源缓存，使用索引作为键
    private var cache = [Int : PhotoAsset]()
    
    // RandomAccessCollection 协议要求的起始索引
    var startIndex: Int { 0 }
    // RandomAccessCollection 协议要求的结束索引
    var endIndex: Int { fetchResult.count }
    
    /// 使用 Photos 框架的查询结果初始化集合
    init(_ fetchResult: PHFetchResult<PHAsset>) {
        self.fetchResult = fetchResult
    }

    /// 通过下标访问照片资源
    /// 优先从缓存中获取，如果没有则创建新的 PhotoAsset 并缓存
    subscript(position: Int) -> PhotoAsset {
        if let asset = cache[position] {
            return asset
        }
        let asset = PhotoAsset(phAsset: fetchResult.object(at: position), index: position)
        cache[position] = asset
        return asset
    }
    
    /// 获取所有原始的 PHAsset 对象
    var phAssets: [PHAsset] {
        var assets = [PHAsset]()
        fetchResult.enumerateObjects { (object, count, stop) in
            assets.append(object)
        }
        return assets
    }
}

// MARK: - Sequence & IteratorProtocol
/// 实现序列和迭代器协议，支持 for-in 循环遍历
extension PhotoAssetCollection: Sequence, IteratorProtocol {
    /// 返回下一个照片资源，用于迭代
    func next() -> PhotoAsset? {
        if iteratorIndex >= count {
            return nil
        }
        
        defer {
            iteratorIndex += 1
        }
        
        return self[iteratorIndex]
    }
}
