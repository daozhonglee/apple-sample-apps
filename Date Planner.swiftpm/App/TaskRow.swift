/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

/// 任务行视图
/// 用于显示和编辑单个任务项
struct TaskRow: View {
    @Binding var task: EventTask          // 任务数据绑定
    var isEditing: Bool                   // 是否处于编辑模式
    @FocusState private var isFocused: Bool   // 输入框焦点状态

    var body: some View {
        HStack {
            // 任务完成状态切换按钮
            Button {
                task.isCompleted.toggle()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(.plain)

            // 任务描述文本或输入框
            if isEditing || task.isNew {
                TextField("Task description", text: $task.text)
                    .focused($isFocused)
                    .onChange(of: isFocused) { newValue in
                        if newValue == false {
                            task.isNew = false
                        }
                    }
            } else {
                Text(task.text)
            }

            Spacer()
        }
        .padding(.vertical, 10)
        // 新任务自动获取焦点
        .task {
            if task.isNew {
                isFocused = true
            }
        }
    }
        
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(task: .constant(EventTask(text: "Do something!")), isEditing: false)
    }
}
