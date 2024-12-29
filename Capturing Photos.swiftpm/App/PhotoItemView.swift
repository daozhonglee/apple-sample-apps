/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import Photos

/// 照片项视图组件
/// 负责显示单张照片的缩略图，支持异步加载和缓存
struct PhotoItemView: View {
    // 照片资源对象，包含照片的元数据和标识符
    var asset: PhotoAsset
    // 图片缓存管理器，用于优化图片加载性能
    var cache: CachedImageManager?
    // 期望显示的图片尺寸
    var imageSize: CGSize
    
    // 当前显示的图片
    @State private var image: Image?
    // 图片加载请求的标识符，用于取消请求
    @State private var imageRequestID: PHImageRequestID?

    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()      // 允许图片调整大小
                    .scaledToFill()   // 保持宽高比填充整个区域
            } else {
                // 图片加载时显示加载指示器
                ProgressView()
                    .scaleEffect(0.5)
            }
        }
        .task {  // 异步任务，在视图出现时执行
            // 异步加载图片
            guard image == nil, let cache = cache else { return }
            imageRequestID = await cache.requestImage(for: asset, targetSize: imageSize) { result in
                Task {
                    if let result = result {
                        self.image = result.image
                    }
                }
            }
        }
    }
}
