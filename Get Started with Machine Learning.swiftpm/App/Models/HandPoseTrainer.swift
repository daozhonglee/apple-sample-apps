/*
See the License.txt file for this sample’s licensing information.
*/

import Foundation
import CreateML
import CoreML

final class HandPoseTrainer {
    // 图像增强参数设置
    private var augmentationParameters = MLHandPoseClassifier.ImageAugmentationOptions()

    // 手势分类器
    var classifier: MLHandPoseClassifier?

    // 训练会话
    var session: TrainingSession?
        
    // 使用数据模型进行训练
    func train(with dataModel: TrainerDataModel) async throws {
       // 获取训练数据集目录
       guard let trainingDataset = dataModel.currentTrainingDataset?.directory else { return }
       // 创建模型参数
       var modelParameters = MLHandPoseClassifier.ModelParameters()
       
       // 设置验证数据集（如果有）
       if let validationDataset = dataModel.currentValidationDataset?.directory {
           modelParameters.validation = .dataSource(.labeledDirectories(at: validationDataset)) 
       } else {
           modelParameters.validation = .none
       }
       
       // 配置图像增强选项
       augmentationParameters.insert(.rotate)      // 添加旋转增强
       augmentationParameters.insert(.translate)   // 添加平移增强
       augmentationParameters.insert(.horizontallyFlip)  // 添加水平翻转增强
       modelParameters.augmentationOptions = augmentationParameters
       
       // 创建训练数据源
       let trainingDataSource = MLHandPoseClassifier.DataSource.labeledDirectories(at: trainingDataset)
       // 启动训练会话
       try await runTrainingSession(with: trainingDataSource, dataModel: dataModel, modelParameters: modelParameters)
    }
}
