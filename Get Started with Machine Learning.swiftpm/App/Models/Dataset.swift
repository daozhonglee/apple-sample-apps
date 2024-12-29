/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

final class Dataset: ObservableObject, Identifiable {
    // 数据集名称
    @Published var name: String
    // 是否是新数据集
    @Published var isNew: Bool
    // 数据集类型（训练集或验证集）
    let type: DatasetType
    // 可用的手势动作列表
    let moves: [String]

    // 资源目录URL
    var resourceDirectory: URL?

    // 获取数据集目录URL
    var directory: URL? {
        return baseDirectory?.appendingPathComponent(name, isDirectory: true)
    }

    // 判断是否有足够的训练图片
    var hasEnoughImages: Bool {
        guard !subDirectories.isEmpty else { return false }
        let subDirectoryImageCounts = subDirectories.map { getImageCount(for: $0) }
        // 确保每个子目录至少有7张图片
        return !subDirectoryImageCounts.contains { $0 < 7 }
    }

    // 获取基础目录URL
    private var baseDirectory: URL? {
        switch type {
        case .training:
            return URL.trainingDirectoryinDoc
        case .validation:
            return URL.validationDirectoryinDoc
        }
    }

    // 获取所有子目录URL列表
    private var subDirectories: [URL] {
        guard let directory = directory else { return [] }
        var subDirs: [URL] = []
        for move in moves {
            subDirs.append(directory.appendingPathComponent(move.capitalized, isDirectory: true))
        }
        return subDirs
    }

    // 初始化方法
    init(name: String? = nil, type: DatasetType, moves: [String], resourceDirectory: URL? = nil, isNew: Bool = false) {
        self.name = name ?? "New Dataset"
        self.type = type
        self.moves = moves
        self.isNew = isNew

        if let dir = resourceDirectory {
            // 如果提供了资源目录，复制到文档目录
            copyToDocumentDirectory(dir)
        } else {
            // 否则创建新的目录结构
            createDirectories()
        }
    }

    // 获取数据集总图片数量
    func getTotalImageCount() -> Int {
        return directory?.getTotalFilesInDataset() ?? 0
    }
    
    // 获取指定子目录的图片数量
    func getImageCount(for subDirectory: URL) -> Int {
        return subDirectory.directoryContents.count
    }

    // 从指定子目录获取图片URL列表
    func getImages(from subDirectory: URL) -> [URL] {
        let directory = subDirectories.first(where: { $0.lastPathComponent == subDirectory.lastPathComponent })
        return directory?.directoryContents ?? []
    }
    
    // 从指定子目录名称获取图片URL列表
    func getImages(from subDirectoryName: String) -> [URL] {
        let directory = subDirectories.first(where: { $0.lastPathComponent == subDirectoryName })
        return directory?.directoryContents ?? []
    }

    // 创建目录结构
    private func createDirectories() {
        guard let baseDirectory = baseDirectory, let directory = directory else { return }
        do {
            // 创建基础目录和数据集目录
            try FileManager.default.createDirectory(at: baseDirectory)
            try FileManager.default.createDirectory(at: directory)
            // 创建各个手势的子目录
            for subDirectory in subDirectories {
                try FileManager.default.createDirectory(at: subDirectory)
            }
        } catch {
            print("Error creating directories: \(error.localizedDescription)")
        }
    }
    
    // 将资源目录中的内容复制到文档目录
    private func copyToDocumentDirectory(_ resourcesFolder: URL) {
        let subDirectories = resourcesFolder.subDirectories
        for subDirectory in subDirectories {
            let subDir = subDirectory.lastPathComponent.capitalized
            let contents = subDirectory.directoryContents
            for content in contents {
                let fileName = content.lastPathComponent
                guard let newSubDirectory = directory?.appending(path: subDir, directoryHint: .isDirectory) else { return }
                do {
                    try FileManager.default.createDirectory(at: newSubDirectory)
                    let url = newSubDirectory.appending(path: fileName)
                    guard !url.fileExists else { continue }
                    Task {
                        do {
                            try FileManager.default.copyItem(at: content, to: url)
                        } catch {
                            print("Error copying url \(error)")
                        }
                    }
                } catch {
                    print("Error creating directory \(error)")
                }
            }
        }
    }

    // 将目录移动到新位置
    func moveDirectoryTo(_ newName: String) {
        guard let originalDirectory = directory else { return }
        guard let newDirectory = baseDirectory?.appendingPathComponent(newName, isDirectory: true) else { return }
        do {
            try FileManager.default.moveItem(at: originalDirectory, to: newDirectory)
            name = newName
        } catch {
            print("Could not move directory: \(error.localizedDescription)")
        }
    }

    // 删除数据集目录
    func delete() {
        guard let directory = directory else { return }
        do {
            try FileManager.default.deleteDirectory(directory)
        } catch {
            print("Could not delete \(name)'s directory: \(error.localizedDescription)")
        }
    }
}

// 数据集类型枚举
enum DatasetType: String {
    case training   // 训练集
    case validation // 验证集
}
