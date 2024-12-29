/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// 单元格样式修饰器
struct CellStyle: ViewModifier {
    // 圆角半径
    var cornerRadius: CGFloat = 15.0
    // 内边距
    var padding: CGFloat = 15.0
    // 是否禁用
    var disabled: Bool = false
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(disabled ? Color.gray : .black)
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(disabled ? Color.gray : Color.accent)
                    .brightness(disabled ? 0.3 : 0.5)
            }
    }
}

// 图表视图样式修饰器
struct ChartViewStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 250, height: 250)
            .padding()
            .cornerRadius(10)
            .padding()
    }
}

// 游戏标签背景修饰器
struct GameLabelBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(.thinMaterial)
            .environment(\.colorScheme, .light)
    }
}

// 胶囊按钮样式
struct CapsuleButton: ButtonStyle {
    // 背景颜色
    var backgroundColor: Color = .white
    // 前景颜色
    var foregroundColor: Color = .accentColor
    // 是否禁用
    var disabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .foregroundColor(foregroundColor.opacity(disabled ? 0.7 : 1.0))
            .background(backgroundColor.opacity(disabled ? 0.5 : 1.0))
            .clipShape(Capsule())
    }
}

// 常量定义
struct Constants {
    // 照片间距
    static let photoSpacing = 12.0
    // 照片圆角半径
    static let photoCornerRadius = 10.0
    // 照片尺寸
    static let photoSize = CGSize(width: 104, height: 104)
}
