/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

/// 相机应用的主入口点
/// 配置全局UI样式并启动应用
@main
struct CameraApp: App {
    /// 初始化应用，设置导航栏外观
    init() {
        UINavigationBar.applyCustomAppearance()
    }
    
    /// 创建应用的主场景
    /// 使用 CameraView 作为根视图
    var body: some Scene {
        WindowGroup {
            CameraView()
        }
    }
}

/// 导航栏外观配置扩展
fileprivate extension UINavigationBar {
    /// 配置导航栏的全局默认外观
    /// 应用半透明模糊效果背景
    static func applyCustomAppearance() {
        let appearance = UINavigationBarAppearance()
        // 设置系统超薄材质的模糊效果
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        // 应用配置到所有导航栏状态
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
