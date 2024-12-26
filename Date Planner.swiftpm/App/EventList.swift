/*
See the License.txt file for this sample's licensing information.
*/

import SwiftUI

/// EventList视图展示了以下SwiftUI核心技术：
/// 1. 环境对象的使用（@EnvironmentObject）
/// 2. 状态管理（@State）
/// 3. List和ForEach的结合使用
/// 4. 导航和模态视图的处理
/// 5. 工具栏的定制
/// 6. 滑动操作的实现
struct EventList: View {
    /// 通过环境对象获取共享的事件数据
    /// @EnvironmentObject允许视图访问父视图提供的数据
    @EnvironmentObject var eventData: EventData
    
    /// 使用@State管理视图本地状态
    /// 这些状态变量的改变会触发视图的重新渲染
    @State private var isAddingNewEvent = false
    @State private var newEvent = Event()
    
    var body: some View {
        List {
            /// 使用ForEach进行列表数据循环, 迭代所有时间段
            /// 展示了如何处理分组列表数据
            ForEach(Period.allCases) { period in
                if !eventData.sortedEvents(period: period).isEmpty {
                    // 创建一个部分视图并使用 ForEach 迭代该时间段内的所有事件。
                    Section(content: {
                        // 使用EventData 中的sortedEvents(period:) 方法返回特定于该部分时间范围的事件。
                        ForEach(eventData.sortedEvents(period: period)) { $event in
                            NavigationLink {
                                EventEditor(event: $event)
                            } label: {
                                EventRow(event: event)
                            }
                            // swipeActions 是 SwiftUI 提供的一个视图修饰符，用于为列表项添加滑动操作功能。
                            .swipeActions {
                                Button(role: .destructive) {
                                    //定义操作代码
                                    eventData.delete(event)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }, header: {
                        Text(period.name)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                    })
                }
            }
        }
        .navigationTitle("Date Planner")
        /// 工具栏的实现：展示如何添加自定义工具栏按钮
        .toolbar {
            // 添加新事件的工具栏按钮
            ToolbarItem {
                Button {
                    newEvent = Event()
                    isAddingNewEvent = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        /// 模态视图的处理：使用sheet修饰符展示新建事件界面
        /// isPresented绑定控制模态视图的显示和隐藏
        .sheet(isPresented: $isAddingNewEvent) {
            NavigationView {
                EventEditor(event: $newEvent, isNew: true)
            }
        }
    }
}

/// 预览提供器：用于SwiftUI预览画布
/// 展示了如何设置预览环境和依赖注入
struct EventList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventList().environmentObject(EventData())

        }
    }
}
