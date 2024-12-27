/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
//本演练展示了如何创建图像网格，并具有照片选取和编辑功能。

@main
struct ImageGalleryApp: App {
    // SwiftUI 管理状态对象的存储，并在发布的值发生更改时更新使用该值的所有子视图。
    @StateObject var dataModel = DataModel()

    var body: some Scene {
        //WindowGroup 是 SwiftUI 应用程序的根容器，
        // 窗口管理：
        //    在 iOS 上，它管理应用的主窗口
        //    在 macOS 上，它允许用户创建多个窗口实例
        //    自动处理窗口的生命周期管理
        //    场景构建：
        //    作为 Scene 协议的具体实现
        //    定义应用程序 UI 的入口点
        //    为应用提供基本的窗口行为
        WindowGroup {
            NavigationStack {
                GridView()
            }
            // 使用 .environmentObject 修饰符传入 DataModel 实例，使dataModel可供所有 NavigationStack 的子视图使用
            .environmentObject(dataModel)
            .navigationViewStyle(.stack)
        }
    }
}
