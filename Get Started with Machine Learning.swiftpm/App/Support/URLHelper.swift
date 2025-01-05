/*
See the License.txt file for this sample’s licensing information.
*/

import Foundation

// URL扩展：提供文件和目录操作的便捷方法
extension URL {
    // 文档目录URL
    static var documentDirectory: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    // 模型存储目录
    static var modelDirectory: URL? {
        return documentDirectory?.appendingPathComponent("Models", isDirectory: true)
    }

    // 文档中的训练数据目录
    static var trainingDirectoryinDoc: URL? {
        return documentDirectory?.appendingPathComponent("Training", isDirectory: true)
    }

    // 文档中的验证数据目录
    static var validationDirectoryinDoc: URL? {
        return documentDirectory?.appendingPathComponent("Validation", isDirectory: true)
    }

    // 资源包中的数据集目录
    static var datasetDirectory: URL? {
        return resourceDirectory?.appendingPathComponent("Dataset", isDirectory: true)
    }

    // 资源包中的训练数据目录
    static var trainingDirectoryInResources: URL? {
        return datasetDirectory?.appendingPathComponent("Training", isDirectory: true)
    }

    // 资源包中的验证数据目录
    static var validationDirectoryInResources: URL? {
        return datasetDirectory?.appendingPathComponent("Validation", isDirectory: true)
    }
    
    // 资源目录URL
    static var resourceDirectory: URL? = Bundle.main.resourceURL
    
    // 默认机器学习模型URL
    static var defaultMLModel: URL? {
        return resourceDirectory?.appendingPathComponent("rockpaperscissors.mlmodel")
    }
    
    // 获取子目录列表
    var subDirectories: [URL] {
        guard self.directoryExists else { return [] }
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: self,
                                                                   includingPropertiesForKeys: [],
                                                                   options: [.skipsHiddenFiles]).filter(\.hasDirectoryPath)
            return urls.sorted { $0.path < $1.path }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return []
    }
    
    // 获取目录内容
    var directoryContents: [URL] {
        guard self.directoryExists else { return [] }
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: self,
                                                                   includingPropertiesForKeys: [],
                                                                   options: [.skipsHiddenFiles,
                                                                             .skipsPackageDescendants,
                                                                             .skipsSubdirectoryDescendants])
            return urls.sorted { $0.path < $1.path }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return []
    }

    // 按日期排序的目录内容
    var directoryContentsOrderedByDate: [URL] {
        guard self.directoryExists else { return [] }
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: self,
                                                                   includingPropertiesForKeys: [.creationDateKey],
                                                                   options: [.skipsHiddenFiles,
                                                                             .skipsPackageDescendants,
                                                                             .skipsSubdirectoryDescendants])
            do {
                return try urls.sorted {
                    try $0.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast > $1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                }
            } catch {
                return urls
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return []
    }

    // 检查目录是否存在
    var directoryExists: Bool {
        var isDir: ObjCBool = true
        let path = self.path
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    }
    
    // 检查文件是否存在
    var fileExists: Bool {
        var isDir: ObjCBool = false
        let path = self.path
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    }
    
    // 获取数据集中的总文件数
    func getTotalFilesInDataset() -> Int {
        let count = subDirectories.map{ $0.directoryContents.count }.reduce(0, +)
        return count
    }
}

// FileManager扩展：提供文件操作的便捷方法
extension FileManager {
    // 创建目录
    func createDirectory(at url: URL) throws {
        guard !url.directoryExists else {
            return
        }
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    // 删除文件
    func delete(_ url: URL) throws {
        if url.fileExists {
            try FileManager.default.removeItem(at: url)
        }
    }

    // 删除目录
    func deleteDirectory(_ url: URL) throws {
        if url.directoryExists {
            try FileManager.default.removeItem(at: url)
        }
    }
}

// Task扩展：提供异步延迟功能
extension Task where Success == Never, Failure == Never {
    // 异步延迟执行
    static func sleep(seconds: Double) async {
        let duration = UInt64(seconds * 1_000_000_000)
        do {
            try await Task.sleep(nanoseconds: duration)
        } catch { }
    }
}
