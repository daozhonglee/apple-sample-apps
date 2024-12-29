/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// Color扩展：定义应用程序使用的颜色
extension Color {
    // 描边颜色：半透明白色
    static var strokeColor: Color { white.opacity(0.5) }
    // 半透明黑色
    static var translucentBlack: Color { black.opacity(0.5) }
    // 强调色：靛蓝色
    static var accent: Color { Color.indigo }
    // 标签强调色：深紫色
    static var labelAccent: Color { Color(red: 0.224, green: 0.0, blue: 0.263) }
}
