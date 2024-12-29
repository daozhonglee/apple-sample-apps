/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

/// 缩略图视图组件，用于显示照片的缩略图
struct ThumbnailView: View {
    // 要显示的图片
    var image: Image?
    
    var body: some View {
        // 使用ZStack创建层叠布局
        ZStack {
            // 设置白色背景
            Color.white
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
            }
        }
        // 设置固定尺寸和圆角
        .frame(width: 41, height: 41)
        .cornerRadius(11)
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static let previewImage = Image(systemName: "photo.fill")
    static var previews: some View {
        ThumbnailView(image: previewImage)
    }
}
