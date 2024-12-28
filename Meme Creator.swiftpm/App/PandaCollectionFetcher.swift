/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// ObservableObject 是一个协议，使类能够与SwiftUI的数据流系统集成
// 当类中的 @Published 属性发生变化时，所有依赖这些属性的视图都会自动刷新
class PandaCollectionFetcher: ObservableObject {
    // @Published 属性包装器使属性变成可观察的
    // 任何修改这些属性的操作都会触发视图更新
    @Published var imageData = PandaCollection(sample: [Panda.defaultPanda])  // 存储所有熊猫数据
    @Published var currentPanda = Panda.defaultPanda                          // 当前显示的熊猫

    // API端点URL，用于获取熊猫数据的JSON
    let urlString = "http://playgrounds-cdn.apple.com/assets/pandaData.json"
    
    // 自定义错误类型，用于网络请求错误处理
    // 使用枚举来定义可能出现的错误类型，这是Swift中处理错误的标准方式
    enum FetchError: Error {
        case badRequest    // 表示HTTP请求失败，如404、500等错误
        case badJSON      // 表示JSON解析失败
    }
    
    // fetchData 方法用于从网络获取熊猫数据
    // async 表示这是一个异步方法，可以在后台执行而不阻塞主线程
    // throws 表示这个方法可能抛出上面定义的错误
    func fetchData() async throws {
        // 将字符串URL转换为URL对象
        // guard let 是一种安全的可选值解包方式
        guard let url = URL(string: urlString) else { return }

        // URLSession.shared.data 发起网络请求
        // try await 等待异步操作完成
        // 这行代码会返回两个值：数据和响应
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        
        // 检查HTTP响应状态码
        // as? HTTPURLResponse 将response转换为HTTP响应对象
        // statusCode == 200 检查是否成功（200表示成功）
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { 
            throw FetchError.badRequest 
        }

        // 创建一个在主线程执行的任务
        // @MainActor 确保在主线程执行UI更新
        // Swift并发系统会自动管理线程切换
        Task { @MainActor in
            // JSONDecoder 将JSON数据解码为Swift对象
            // try 表示这个操作可能失败需要错误处理
            imageData = try JSONDecoder().decode(PandaCollection.self, from: data)
        }
    }
}
