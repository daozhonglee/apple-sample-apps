/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

/// SF Symbol样式修饰符
/// 统一设置SF Symbol的显示样式
struct SFSymbolStyling: ViewModifier {
    func body(content: Content) -> some View {
        content
            .imageScale(.large)          // 设置图标大小
            .symbolRenderingMode(.monochrome)    // 设置渲染模式为单色
    }
}

// 视图扩展，添加便捷修饰符方法
extension View {
    func sfSymbolStyling() -> some View {
        modifier(SFSymbolStyling())
    }
}
