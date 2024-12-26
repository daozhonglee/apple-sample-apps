/*
See the License.txt file for this sample's licensing information.
*/

import SwiftUI

/// 故事主视图
/// 使用 NavigationStack 管理页面导航
struct StoryView: View {
    var body: some View {
        // NavigationStack 提供页面间的导航功能
        NavigationStack {
            // 从故事的第一页(索引0)开始显示
            StoryPageView(story: story, pageIndex: 0)
        }
    }
}

/// 提供预览功能
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView()
    }
}
