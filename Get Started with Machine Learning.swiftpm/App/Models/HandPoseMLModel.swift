/*
See the License.txt file for this sample’s licensing information.
*/

import Foundation
import CoreML

final class HandPoseMLModel: NSObject, Identifiable {
    // 模型名称
    let name: String
    // Core ML 模型实例
    let mlModel: MLModel
    // 模型文件URL
    let url: URL
    
    // 获取分类标签
    private var classLabels: [Any] {
        mlModel.modelDescription.classLabels ?? []
    }

    // 初始化方法
    init(name: String, mlModel: MLModel, url: URL) {
        self.name = name
        self.mlModel = mlModel
        self.url = url
    }

    // 进行手势预测
    func predict(poses: HandPoseInput) throws -> HandPoseOutput? {
        // 使用模型进行预测
        let features = try mlModel.prediction(from: poses)
        // 创建输出对象
        let output = HandPoseOutput(features: features)
        return output
    }
}

// 手势输入数据类
class HandPoseInput {
    // 手势姿势的多维数组数据
    var poses: MLMultiArray
    
    // 初始化方法
    init(poses: MLMultiArray) {
        self.poses = poses
    }
}

// 手势预测输出类
class HandPoseOutput {
    // ML特征提供者
    let provider : MLFeatureProvider

    // 延迟加载的标签概率字典
    lazy var labelProbabilities: [String : Double] = { [unowned self] in
        self.getOutputProbabilities()
    }()

    // 延迟加载的预测标签
    lazy var label: String = { [unowned self] in
        self.getOutputLabel()
    }()

    // 使用特征提供者初始化
    init(features: MLFeatureProvider) {
        self.provider = features
    }
}
