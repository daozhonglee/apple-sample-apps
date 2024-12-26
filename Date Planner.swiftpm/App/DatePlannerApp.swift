/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// 该demo 讲解了应用程序如何通过创建单个数据对象并将其提供给整个视图层次结构来与其视图共享数据。
@main
struct DatePlannerApp: App {
    /// 在这里使用@StateObject创建一个事件数据模型实例确保了eventData在整个app生命周期中保持存在
    // @StateObject 用于创建可观察对象, 由于该对象是可观察的，因此 SwiftUI 会监视它以跟踪其值的任何更改。每当数据发生变化时，SwiftUI 都会自动更新所有使用（或观察）它的视图。
    @StateObject private var eventData = EventData()

    var body: some Scene {
        WindowGroup {
            // 要在应用程序中的不同视图之间导航，请创建一个 NavigationView 作为视图层次结构中的顶级视图，并插入应用程序的主视图
            NavigationView {
                EventList()
                Text("Select an Event")
                    .foregroundStyle(.secondary)
            }
            // 使用 .environmentObject 修饰符并传入 eventData 实例。可以让 eventData在所有导航视图的子视图（及其子视图）中使用
            .environmentObject(eventData)
        }
    }
}
