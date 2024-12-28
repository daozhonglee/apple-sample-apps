/*
See the License.txt file for this sample’s licensing information.
*/

import Foundation

// ObservableObject 协议使类可以在 SwiftUI 中被观察
class DataModel: ObservableObject {
    // @Published 属性包装器使得属性变化时自动通知观察者
    @Published var items: [Item] = []
    
    init() {

        // 从文档目录加载的图片
        //FileManager 是一个用于管理文件系统的类，提供了创建、删除、移动、复制文件和目录的功能，以及查询文件属性等操作。它是与文件系统交互的核心工具
        if let documentDirectory = FileManager.default.documentDirectory {
            debugPrint("333",documentDirectory, FileManager.default.getContentsOfDirectory(documentDirectory))
            let urls = FileManager.default.getContentsOfDirectory(documentDirectory).filter { $0.isImage }
            for url in urls {
//                debugPrint("1111 Loading image from document directory: \(url)")
                let item = Item(url: url)
                items.append(item)
            }
        }

        // 从应用程序包中加载默认图片
        //在 iOS、macOS 等 Apple 平台的应用开发中，主应用程序包（Main Bundle） 是指包含应用程序可执行文件及其所有相关资源（如图片、音频、故事板、本地化文件等）的目录。它是应用程序的核心部分，由 Xcode 在构建应用时自动生成。
        // forResourcesWithExtension ext: String? 指定要查找的资源文件的扩展名。
        // subdirectory subpath: String?  指定要查找的资源文件所在的子目录路径。
        if let urls = Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: nil) {
            //  URL 是 Foundation 框架中的 URL 类型，用于表示资源文件的位置路径。URL 是 Swift 中用于处理文件路径、网络地址等资源的通用类型。
            for url in urls {
//                debugPrint("22222 Loading image from main bundle: \(url)")
                let item = Item(url: url)
                items.append(item)
            }
        }
    }
    
    func addItem(_ item: Item) {
        items.insert(item, at: 0)
    }
    
    func removeItem(_ item: Item) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
            FileManager.default.removeItemFromDocumentDirectory(url: item.url)
        }
    }
}

// URL 扩展用于判断文件是否为图片
extension URL {
    /// Indicates whether the URL has a file extension corresponding to a common image format.
    var isImage: Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "heic"]
        return imageExtensions.contains(self.pathExtension)
    }
}

