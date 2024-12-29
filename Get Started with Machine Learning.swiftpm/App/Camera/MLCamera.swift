/*
See the License.txt file for this sample’s licensing information.
*/

// 导入基础框架
import Foundation
// 导入视觉框架用于手势识别
import Vision

// MLCamera: 机器学习相机类
// 继承自基础相机类，添加手势识别和机器学习模型支持
final class MLCamera: Camera {
    // 手势识别请求，用于检测用户手部姿势
    lazy var handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        // 设置最大检测手势数量为1
        request.maximumHandCount = 1
        return request
    }()
    
    // 当前使用的机器学习模型
    var currentMLModel: HandPoseMLModel?
}
