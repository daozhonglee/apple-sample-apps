/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// @main 标记应用程序的入口点
// 每个SwiftUI应用程序必须有且仅有一个带有@main的结构体
@main 
struct MemeCreatorApp: App {
    // @StateObject 是一个属性包装器，用于创建和管理引用类型的数据模型
    // 它会在视图的整个生命周期内保持数据模型的存在
    // 即使视图重新渲染，数据模型也不会被重新创建
    // private 修饰符确保数据模型的访问范围仅限于当前文件
    @StateObject private var fetcher = PandaCollectionFetcher()
    
    var body: some Scene {
        // WindowGroup 是SwiftUI提供的基本场景类型
        // 它为应用程序提供了一个标准的窗口环境
        WindowGroup {
            // NavigationStack 提供了视图导航功能
            // 允许在视图之间进行push和pop操作
            NavigationStack {
                // environmentObject 是一个视图修饰符
                // 它将fetcher注入到整个视图层级中
                // 这样所有子视图都可以通过 @EnvironmentObject 访问到这个对象
                // 这是SwiftUI中实现依赖注入的标准方式
                MemeCreator()
                    .environmentObject(fetcher)
            }
        }
    }
}
