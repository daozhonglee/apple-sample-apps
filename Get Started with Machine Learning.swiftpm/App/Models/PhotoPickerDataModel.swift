/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import PhotosUI

final class PhotoPickerDataModel: ObservableObject {
    // 选中的照片项目数组
    @Published var selection: [PhotosPickerItem] = []
    
    // 将选中的照片项目添加到指定目录
    func addImageFromPickerItem(_ pickerItem: PhotosPickerItem, to directory: URL) async {
        do {
            // 尝试加载可传输的图片文件
            guard let imageFile = try await pickerItem.loadTransferable(type: PhotoFile.self) else { return  }
            // 创建目标URL
            let destURL = directory.appending(path: imageFile.name, directoryHint: .notDirectory)
            // 移动文件到目标位置
            try FileManager.default.moveItem(at: imageFile.url, to: destURL)
        } catch {
            print("Error creating item from picked photo: \(error.localizedDescription)")
        }
    }
}

// 可传输的照片文件结构体
struct PhotoFile: Transferable {
    // 文件名
    let name: String
    // 文件URL
    let url: URL
    
    // 传输表示
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .image, shouldAttemptToOpenInPlace: false) { data in
            // 发送文件
            SentTransferredFile(data.url, allowAccessingOriginalFile: true)
        } importing: { received in
            // 导入文件
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = received.file.lastPathComponent
            let destinationURL = tempDirectory.appendingPathComponent(fileName)
            try FileManager.default.copyItem(at: received.file, to: destinationURL)
            return Self.init(name: fileName, url: destinationURL)
        }
    }
}
