/*
See the License.txt file for this sample's licensing information.
*/

import SwiftUI

/// 故事页面视图
/// 显示故事内容和选择项
struct StoryPageView: View {
    // 当前故事对象
    let story: Story
    // 当前页面索引
    let pageIndex: Int

    var body: some View {
        VStack {
            // 使用 ScrollView 显示故事文本内容
            ScrollView {
                Text(story[pageIndex].text)
            }
            
            // 遍历显示所有选择项 
            // choices 数组中的每个选项都会创建一个导航链接
            // id: \.text 使用选项文本作为唯一标识符
            ForEach(story[pageIndex].choices, id: \Choice.text) { choice in
                // 创建导航链接，点击后跳转到选择对应的新页面
                // destination 参数指定目标页面，使用选择项中的 destination 索引创建新的 StoryPageView
                NavigationLink(destination: StoryPageView(story: story, pageIndex: choice.destination)) {
                    // 选项的文本内容和样式设置
                    Text(choice.text)
                        .multilineTextAlignment(.leading)  // 文本左对齐
                        .frame(maxWidth: .infinity, alignment: .leading)  // 框架占据最大宽度，内容左对齐
                        .padding()  // 添加内边距
                        .background(Color.gray.opacity(0.25))  // 设置灰色半透明背景
                        .cornerRadius(8)  // 设置圆角
                }
            }
        }
        .padding()
        //.navigationTitle 修饰符设置导航栏标题
        .navigationTitle("Page \(pageIndex + 1)")
        // .navigationBarTitleDisplayMode 修饰符控制标题在导航栏中的显示方式。提供 .inline 作为修饰符的值会使标题尺寸更小。您可以尝试其他两个可能的值 - .automatic 和 .large - 看看它们使应用程序看起来如何。
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// 预览提供者
struct NonlinearStory_Previews: PreviewProvider {
    static var previews: some View {
        StoryPageView(story: story, pageIndex: 0)
    }
}
