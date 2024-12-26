/*
See the License.txt file for this sample's licensing information.
*/

import SwiftUI

/// 故事应用的主入口点
/// 负责初始化和配置应用程序
@main
struct StoryApp: App {
    var body: some Scene {
        WindowGroup {
            // 设置 StoryView 作为应用的根视图
            StoryView()
        }
    }
}
