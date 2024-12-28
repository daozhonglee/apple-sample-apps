/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// Codable 协议是 Encodable & Decodable 的组合
// 它使结构体可以自动支持JSON的编码和解码
// 这是Swift中处理JSON数据的标准方式
struct Panda: Codable {
    // description 属性存储熊猫图片的描述文本
    // 属性名必须与JSON数据中的键名完全匹配
    var description: String
    
    // imageUrl 是一个可选的URL类型
    // 使用可选类型（Optional）是Swift的一个重要特性
    // 它可以安全地处理值缺失的情况
    // URL? 表示这个属性可能是一个URL，也可能是nil
    var imageUrl: URL?
    
    // static 类型属性，用于提供默认值
    // 这是一个常量（let），创建后不能修改
    // 用于应用启动时的初始状态或加载失败时的后备数据
    static let defaultPanda = Panda(
        description: "Cute Panda",
        imageUrl: URL(string: "https://assets.devpubs.apple.com/playgrounds/_assets/pandas/pandaBuggingOut.jpg")
    )
}

// PandaCollection 结构体用于存储多个Panda对象
// 它对应API返回的JSON数组
struct PandaCollection: Codable {
    // sample 是一个存储Panda实例的数组
    // [Panda] 是Swift的数组类型写法，表示"Panda类型的数组"
    var sample: [Panda]
}
