/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import os.log

/// 照片集合视图，用于显示相册中的所有照片
/// 采用网格布局展示缩略图
struct PhotoCollectionView: View {
    // 照片集合数据模型
    @ObservedObject var photoCollection: PhotoCollection
    
    // 获取当前设备的显示比例
    @Environment(\.displayScale) private var displayScale
        
    // 定义网格布局的常量
    private static let itemSpacing = 12.0         // 照片之间的间距
    private static let itemCornerRadius = 15.0    // 照片圆角半径
    private static let itemSize = CGSize(width: 90, height: 90)  // 照片尺寸
    
    /// 根据设备显示比例计算实际需要的图片尺寸
    /// 限制最大比例为2，避免内存占用过大
    private var imageSize: CGSize {
        return CGSize(width: Self.itemSize.width * min(displayScale, 2), height: Self.itemSize.height * min(displayScale, 2))
    }
    
    // 定义网格列的布局
    private let columns = [
        GridItem(.adaptive(minimum: itemSize.width, maximum: itemSize.height), spacing: itemSpacing)
    ]
    
    var body: some View {
        ScrollView {
            /// LazyVGrid实现照片网格布局
            /// 使用自适应列宽实现流式布局
            LazyVGrid(columns: columns, spacing: Self.itemSpacing) {
                ForEach(photoCollection.photoAssets) { asset in
                    // 导航到照片详情视图
                    NavigationLink {
                        PhotoView(asset: asset, cache: photoCollection.cache)
                    } label: {
                        photoItemView(asset: asset)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(asset.accessibilityLabel)
                }
            }
            .padding([.vertical], Self.itemSpacing)
        }
        .navigationTitle(photoCollection.albumName ?? "Gallery")
        .navigationBarTitleDisplayMode(.inline)
        .statusBar(hidden: false)
    }
    
    /// 创建单个照片项的视图
    /// - Parameter asset: 照片资源
    /// - Returns: 包含照片缩略图和收藏标记的视图
    private func photoItemView(asset: PhotoAsset) -> some View {
        PhotoItemView(asset: asset, cache: photoCollection.cache, imageSize: imageSize)
            .frame(width: Self.itemSize.width, height: Self.itemSize.height)
            .clipped()
            .cornerRadius(Self.itemCornerRadius)
            // 如果照片被收藏，显示收藏图标
            .overlay(alignment: .bottomLeading) {
                if (asset.isFavorite) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 1)
                        .font(.callout)
                        .offset(x: 4, y: -4)
                }
            }
            // 视图出现时开始缓存图片
            .onAppear {
                Task {
                    await photoCollection.cache.startCaching(for: [asset], targetSize: imageSize)
                }
            }
            // 视图消失时停止缓存
            .onDisappear {
                Task {
                    await photoCollection.cache.stopCaching(for: [asset], targetSize: imageSize)
                }
            }
    }
}
