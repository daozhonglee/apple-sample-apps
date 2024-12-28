/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// EntryBannerTheme: 根据不同主题展示对应的横幅视图
struct EntryBannerTheme: View {
    var forTheme: JournalTheme
    var body: some View {
        switch forTheme {
        case .line:
            YourTitleBannerView()
        case .curve:
            CurveThemeView()
        case .dot:
            DotThemeView()
        case .ray:
            RayThemeView()
        case .wave:
            WaveThemeView()
        }
    }
}

// BackgroundIcon: 根据主题显示对应的图标
struct BackgroundIcon: View {
    var forTheme: JournalTheme
    var body: some View {
        switch forTheme {
        case .line:
            Image("LineIcon")
                .resizable()
        case .curve:
            Image("CurveIcon")
                .resizable()
        case .dot:
            Image("DotIcon")
                .resizable()
        case .ray:
            Image("RayIcon")
                .resizable()
            
        case .wave:
            Image("WaveIcon")
                .resizable()
        }
    }
}

// EntryBackground: 根据主题显示对应的背景图片
struct EntryBackground: View {
    var forTheme: JournalTheme
        var body: some View {
            switch forTheme {
            case .line:
                Image("LineBackground")
                    .resizable()
            case .curve:
                Image("CurveBackground")
                    .resizable()
            case .dot:
                Image("DotBackground")
                    .resizable()
            case .ray:
                Image("RayBackground")
                    .resizable()
            case .wave:
                Image("WaveBackground")
                    .resizable()
            }
        }
}

// CardBackground: 定义卡片的背景样式
struct CardBackground: View {
    var theme: JournalTheme = .line
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundColor(getCardBackground(forTheme: theme))
            .shadow(color: Color.shadow, radius: 4)
    }
    
    // 根据主题返回对应的背景颜色
    func getCardBackground(forTheme: JournalTheme) -> Color {
        switch forTheme {
        case .line:
            return Color.paleOrange
        case .curve:
            return Color.curveCard
        case .dot:
            return Color.dotCard
        case .ray:
            return Color.rayCard
        case .wave:
            return Color.waveCard
        }
    }
}

// CardStyle: 卡片样式的视图修饰器
struct CardStyle: ViewModifier {
    var theme: JournalTheme = .line
    func body(content: Content) -> some View {
        content
            .background(CardBackground(theme: theme))
            .padding(5)
    }
}

// JournalFont扩展：为不同字体提供统一的字体设置方法
extension JournalFont {
    // 根据字体类型和大小返回对应的Font对象
    func uiFont( _ size: CGFloat) -> Font{
        switch self {
        case .font1:
            return Font.system(size:size,weight: .medium, design: .rounded)
        case .font2:
            return Font.custom(rawValue, size: size)
           
        case .font3:
            return Font.custom(rawValue, size: size)
        }
    }
}

// FontStyle: 文本样式的视图修饰器
struct FontStyle: ViewModifier {
    var size: CGFloat
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .medium, design: .rounded))
            .foregroundColor(.darkBrown)
    }
}

// EntryBannerStyle: 横幅样式的视图修饰器
struct EntryBannerStyle: ViewModifier {
    var theme: JournalTheme
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .background(CardBackground(theme: theme))
    }
}

// BackgroundStyle: 背景样式的视图修饰器
struct BackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .ignoresSafeArea()
    }
}

// ListRowStyle: 列表行样式的视图修饰器
struct ListRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

// EntryListStyle: 列表整体样式的视图修饰器
struct EntryListStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden)
    }
}
