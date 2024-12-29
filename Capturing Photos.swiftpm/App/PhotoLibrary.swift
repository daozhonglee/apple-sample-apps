/*
See the License.txt file for this sample’s licensing information.
*/

import Photos
import os.log

/// 照片库访问管理类
class PhotoLibrary {
    /// 检查照片库访问权限
    /// - Returns: 返回是否有权限访问照片库
    static func checkAuthorization() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            // 已授权完全访问权限
            logger.debug("Photo library access authorized.")
            return true
        case .notDetermined:
            // 未确定授权状态，请求用户授权
            logger.debug("Photo library access not determined.")
            return await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
        case .denied:
            // 用户拒绝访问
            logger.debug("Photo library access denied.")
            return false
        case .limited:
            // 限制访问权限
            logger.debug("Photo library access limited.")
            return false
        case .restricted:
            // 受限制的访问权限
            logger.debug("Photo library access restricted.")
            return false
        @unknown default:
            return false
        }
    }
}

// 日志记录器
fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "PhotoLibrary")

