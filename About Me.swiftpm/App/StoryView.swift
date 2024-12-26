/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// StoryView 用于展示用户的个人故事内容
struct StoryView: View {
    var body: some View {
        VStack {
            // 页面标题
            Text("My Story")
                .font(.largeTitle)      // 使用大标题字体
                .fontWeight(.bold)      // 设置粗体
                .padding()              // 添加内边距
            
            // ScrollView 创建可滚动视图，适用于长文本内容
            ScrollView {
                Text(information.story) // 显示故事内容
                    .font(.body)        // 使用正文字体
                    .padding()          // 添加内边距
            }
        }
        .padding([.top, .bottom], 50)   // 为整个 VStack 添加上下 50 点的内边距
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView()
    }
}
