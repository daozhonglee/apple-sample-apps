/*
See the License.txt file for this sample's licensing information.
*/

/// 故事模型，包含所有页面
struct Story {
    // 存储所有故事页面
    let pages: [StoryPage]

    // 通过下标访问特定页面
    subscript(_ pageIndex: Int) -> StoryPage {
        return pages[pageIndex]
    }
}

/// 故事页面模型
struct StoryPage {
    // 页面文本内容
    let text: String
    // 该页面的所有选择项
    let choices: [Choice]
    
    init(_ text: String, choices: [Choice]) {
        self.text = text
        self.choices = choices
    }
}

/// 选择项模型
struct Choice {
    // 选择项文本
    let text: String
    // 选择后跳转的目标页面索引
    let destination: Int
}
