/*
See the License.txt file for this sample's licensing information.
*/

import SwiftUI

/// 取景器视图，用于显示相机预览或拍摄的照片
struct ViewfinderView: View {
    // 绑定的图片属性，用于显示相机捕获的图像
    @Binding var image: Image?
    
    var body: some View {
        // 使用GeometryReader获取视图尺寸信息
        GeometryReader { geometry in
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct ViewfinderView_Previews: PreviewProvider {
    static var previews: some View {
        ViewfinderView(image: .constant(Image(systemName: "pencil")))
    }
}
