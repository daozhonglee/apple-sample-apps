/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

/// EventDetail 视图展示了以下 SwiftUI 核心概念：
/// 1. 数据绑定与状态管理
/// 2. 条件渲染
/// 3. 列表视图和自定义行
/// 4. 模态视图的展示
/// 5. 手势处理
struct EventDetail: View {
    /// @Binding 创建对外部数据的引用，实现双向数据绑定
    /// 当父视图的 event 发生变化时，这里也会更新
    @Binding var event: Event
    /// 控制视图是否处于编辑模式
    let isEditing: Bool
    
    /// @State 用于管理视图本地状态
    /// 控制符号选择器是否显示
    @State private var isPickingSymbol = false
    
    var body: some View {
        /// List 用于创建垂直滚动列表
        List {
            /// 事件标题和图标部分
            HStack {
                /// 符号选择按钮
                Button {
                    isPickingSymbol.toggle()
                } label: {
                    Image(systemName: event.symbol)
                        .sfSymbolStyling()  // 自定义SF符号样式
                        .foregroundColor(event.color)
                        .opacity(isEditing ? 0.3 : 1)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 5)

                /// 条件渲染：根据编辑状态显示不同的视图
                if isEditing {
                    /// TextField 用于文本输入
                    TextField("New Event", text: $event.title)
                        .font(.title2)
                } else {
                    /// 静态文本显示
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            
            /// 日期选择部分：根据编辑状态显示不同的日期视图
            if isEditing {
                DatePicker("Date", selection: $event.date)
                    .labelsHidden()
                    .listRowSeparator(.hidden)
            } else {
                HStack {
                    Text(event.date, style: .date)
                    Text(event.date, style: .time)
                }
                .listRowSeparator(.hidden)
            }
            
            /// 任务列表部分
            Text("Tasks")
                .fontWeight(.bold)
            
            /// ForEach 循环展示任务列表
            /// $event.tasks 使用美元符号表示对数组的绑定
            ForEach($event.tasks) { $item in
                TaskRow(task: $item, isEditing: isEditing)
            }
            /// .onDelete 修饰符添加滑动删除功能
            .onDelete(perform: { indexSet in
                event.tasks.remove(atOffsets: indexSet)
            })
            
            /// 添加任务按钮
            Button {
                event.tasks.append(EventTask(text: "", isNew: true))
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Task")
                }
            }
            .buttonStyle(.borderless)
        }
        /// 条件编译：仅在 iOS 平台设置导航栏样式
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        /// sheet 修饰符用于显示模态视图
        /// 当 isPickingSymbol 为 true 时显示符号选择器
        .sheet(isPresented: $isPickingSymbol) {
            SymbolPicker(event: $event)
        }
    }
}

/// 预览提供器
struct EventDetail_Previews: PreviewProvider {
    static var previews: some View {
        EventDetail(event: .constant(Event.example), isEditing: true)
    }
}
