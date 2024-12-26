/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

/// EventEditor展示了以下SwiftUI核心技术：
/// 1. 数据绑定(@Binding)
/// 2. 环境值的使用(@Environment)
/// 3. 状态管理(@State)
/// 4. 工具栏的自定义
/// 5. 视图的条件渲染
struct EventEditor: View {
    /// @Binding用于创建对外部状态的引用，实现双向数据绑定
    @Binding var event: Event
    var isNew = false
    
    /// @State用于管理视图本地状态
    @State private var isDeleted = false
    /// 使用环境对象访问共享数据
    @EnvironmentObject var eventData: EventData
    /// @Environment用于访问环境值，这里用于获取dismiss动作
    @Environment(\.dismiss) private var dismiss
    
    /// 本地状态管理
    @State private var eventCopy = Event()
    @State private var isEditing = false
    
    /// 计算属性：检查事件是否已被删除
    private var isEventDeleted: Bool {
        !eventData.exists(event) && !isNew
    }
    
    var body: some View {
        VStack {
            /// 主要内容视图
            EventDetail(event: $eventCopy, isEditing: isNew ? true : isEditing)
                /// 工具栏配置：展示如何根据不同状态显示不同的按钮
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if isNew {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                    }
                    //ToolbarItem 用于在导航栏或工具栏添加自定义按钮和控件
                    // placement 属性控制项目在工具栏中的位置
                    // 常用位置包括：
                    // .navigationBarLeading: 左侧
                    // .navigationBarTrailing: 右侧
                    // .principal: 中间
                    // .bottomBar: 底部工具栏
                    // .cancellationAction: 取消按钮位置
                    // .primaryAction: 主要操作位置
                    ToolbarItem {
                        Button {
                            if isNew {
                                eventData.events.append(eventCopy)
                                dismiss()
                            } else {
                                if isEditing && !isDeleted {
                                    print("Done, saving any changes to \(event.title).")
                                    withAnimation {
                                        event = eventCopy // Put edits (if any) back in the store.
                                    }
                                }
                                isEditing.toggle()
                            }
                        } label: {
                            Text(isNew ? "Add" : (isEditing ? "Done" : "Edit"))
                        }
                    }
                }
                /// 视图生命周期处理
                .onAppear {
                    eventCopy = event // Grab a copy in case we decide to make edits.
                }
                .disabled(isEventDeleted)

            /// 条件渲染：仅在编辑模式显示删除按钮
            if isEditing && !isNew {

                Button(role: .destructive, action: {
                    isDeleted = true
                    dismiss()
                    eventData.delete(event)
                }, label: {
                    Label("Delete Event", systemImage: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                })
                    .padding()
            }
        }
        /// 使用overlay添加删除状态的视觉反馈
        .overlay(alignment: .center) {
            if isEventDeleted {
                Color(UIColor.systemBackground)
                Text("Event Deleted. Select an Event.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// 预览提供器
struct EventEditor_Previews: PreviewProvider {
    static var previews: some View {
        EventEditor(event: .constant(Event()))
    }
}
