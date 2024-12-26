/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        VStack {
            // 标题文本
            Text("All About")
                .font(.largeTitle)     // 使用大标题字体
                .fontWeight(.bold)      // 设置字体粗细为粗体
                .padding()              // 添加边距
            
            // 显示用户头像
            Image(information.image)
                .resizable()            // 允许图像适应屏幕上的可用空间；否则图像将以其完整尺寸显示，这可能会非常大。
                .aspectRatio(contentMode: .fit)  // .aspectRatio 要求图像保持其纵横比。通过指定 .fit，您要求 SwiftUI 调整图像大小，使其适合可用空间。
                .cornerRadius(10)       // 添加圆角
                .padding(40)            // 设置四周边距为40
            
            // 显示用户姓名
            Text(information.name)
                .font(.title)           // 使用标题字体
        }
    }
}

// 预览提供者
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
