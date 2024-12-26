
import SwiftUI

/// AboutMeApp 是该应用的主入口点
/// 遵循 App 协议，使用 @main 标记为应用程序的启动点
@main
struct AboutMeApp: App {
    /// 定义应用的场景结构
    /// 返回一个包含主 ContentView 的窗口组
    var body: some Scene {
        WindowGroup {
            // 将 ContentView 设置为应用的根视图
            ContentView()
        }
    }
}
