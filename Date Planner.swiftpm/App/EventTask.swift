/*
See the License.txt file for this sample's licensing information.
*/

import Foundation

/// 事件任务结构体
/// 用于表示事件中的单个任务项
struct EventTask: Identifiable, Hashable {
    /// 任务唯一标识符
    var id = UUID()
    /// 任务描述文本
    var text: String
    /// 任务是否完成
    var isCompleted = false
    /// 是否为新任务
    var isNew = false
}
