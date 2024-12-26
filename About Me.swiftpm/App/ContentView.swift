/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// ContentView 作为应用的根视图，负责管理所有主要标签页面
struct ContentView: View {
    var body: some View {
        // TabView 创建一个标签式界面，允许用户在不同视图之间切换
        TabView {
            // 主页视图 - 显示用户基本信息
            HomeView()
            // .tabItem 是 SwiftUI 中用于定制 TabView 中各个标签页外观的修饰符：用于设置标签栏中的图标和文本
            // 只能在 TabView 的直接子视图上使用
            // 通常搭配 Label 组件来定义图标和文字
                .tabItem {
                    Label("Home", systemImage: "person") // 使用人物图标
                }

            StoryView()
                .tabItem {
                    Label("Story", systemImage: "book") // 使用书本图标
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star") // 使用星星图标
                }
            
            FunFactsView()
                .tabItem {
                    Label("Fun Facts", systemImage: "hand.thumbsup") // 使用点赞图标
                }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
