/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import PhotosUI

// UIViewControllerRepresentable 协议允许在 SwiftUI 中使用 UIKit 的视图控制器
struct PhotoPicker: UIViewControllerRepresentable {
    // @EnvironmentObject 用于在视图层次结构中共享数据
    @EnvironmentObject var dataModel: DataModel
    
    // @Environment 用于访问环境值，这里用于关闭当前视图
    @Environment(\.dismiss) var dismiss
    
    // 创建 PHPickerViewController 实例
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoPicker>) -> PHPickerViewController {
        
        // 配置照片选择器
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .images // 仅显示图片
        configuration.preferredAssetRepresentationMode = .current // 避免转码

        let photoPickerViewController = PHPickerViewController(configuration: configuration)
        photoPickerViewController.delegate = context.coordinator
        return photoPickerViewController
    }
    
    /// Creates the coordinator that allows the picker to communicate back to this object.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// Updates the picker while it’s being presented.
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<PhotoPicker>) {
        // No updates are necessary.
    }
}

// Coordinator 用于处理 UIKit 的代理回调
class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    let parent: PhotoPicker
    
    /// Called when one or more items have been picked, or when the picker has been canceled.
    // 处理用户选择图片后的回调
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // Dismisss the presented picker.
        self.parent.dismiss()
        
        guard
            let result = results.first,
            result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
        else { return }
        
        // Load a file representation of the picked item.
        // This creates a temporary file which is then copied to the app’s document directory for persistent storage.
        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
            if let error = error {
                print("Error loading file representation: \(error.localizedDescription)")
            } else if let url = url {
                if let savedUrl = FileManager.default.copyItemToDocumentDirectory(from: url) {
                    // Add the new item to the data model.
                    // 使用 Task 和 @MainActor 确保在主线程上更新 UI
                    Task { @MainActor [dataModel = self.parent.dataModel] in
                        withAnimation {
                            let item = Item(url: savedUrl)
                            dataModel.addItem(item)
                        }
                    }
                }
            }
        }
    }
    
    init(_ parent: PhotoPicker) {
        self.parent = parent
    }
}
