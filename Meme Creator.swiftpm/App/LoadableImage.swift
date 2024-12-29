/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct LoadableImage: View {
    // 接收Panda模型数据作为参数
    var imageMetadata: Panda
    
    var body: some View {
        // AsyncImage 是SwiftUI提供的异步图片加载组件
        // 它会自动处理图片的下载和缓存
        AsyncImage(url: imageMetadata.imageUrl) { phase in 
            // phase参数包含三种状态：empty（初始状态）、success（加载成功）、failure（加载失败）
            if let image = phase.image {
                // 图片加载成功后的处理
                image
                    .resizable()           // 允许图片调整大小
                    .scaledToFit()         // 保持宽高比例缩放
                    .cornerRadius(15)       // 添加圆角
                    .shadow(radius: 5)      // 添加阴影效果
                    // 无障碍功能配置
                    .accessibility(hidden: false)
                    .accessibilityLabel(Text(imageMetadata.description))
            }  else if phase.error != nil  {
                // 图片加载失败时显示的占位符视图
                VStack {
                    Image("pandaplaceholder")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300)
                    Text("The pandas were all busy.")
                        .font(.title2)
                    Text("Please try again.")
                        .font(.title3)
                }
                
            } else {
                // 加载过程中显示进度指示器
                ProgressView()
            }
        }
    }
}

// 预览提供器，用于在Xcode中预览视图
struct Panda_Previews: PreviewProvider {
    static var previews: some View {
        LoadableImage(imageMetadata: Panda.defaultPanda)
    }
}
