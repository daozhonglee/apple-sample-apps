/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import CoreML
import CreateML

final class TrainerDataModel: ObservableObject {
    // 训练状态枚举
    enum State: String {
        case inactive   // 未激活
        case active    // 正在训练
        case finished  // 训练完成
        case error     // 发生错误
    }

    // 训练指标
    var trainingMetrics = TrainingMetrics()

    // 发布的属性
    @Published var modelName: String?  // 模型名称
    @Published var currentTrainer: HandPoseTrainer?  // 当前训练器
    @Published var currentTrainingDataset: Dataset?  // 当前训练数据集
    @Published var currentValidationDataset: Dataset?  // 当前验证数据集
    @Published var completed: Double = 0.0  // 完成进度
    @Published var currentPhase: String = ""  // 当前训练阶段
    @Published var currentState: State = .inactive  // 当前状态

    // 是否禁用训练按钮
    var disableTrainingButton: Bool {
        guard let modelName = modelName, !modelName.isEmpty, let trainingDataset = currentTrainingDataset else { return true }
        return !trainingDataset.hasEnoughImages
    }
    
    // 获取本地训练数据集列表
    var localTrainingDatasets: [Dataset] {
        guard let trainingDirectory = URL.trainingDirectoryInResources else { return [] }
        var datasets: [Dataset] = []
        // 遍历训练目录中的所有文件夹
        for localURL in trainingDirectory.directoryContents {
            let folderName = localURL.lastPathComponent
            // 为每个文件夹创建数据集对象
            let dataset = Dataset(name: folderName,
                    type: .training,
                    moves: moves,
                    resourceDirectory: localURL)
            datasets.append(dataset)
        }
        return datasets
    }
    
    // 获取本地验证数据集列表
    var localValidationDatasets: [Dataset] {
        guard let trainingDirectory = URL.validationDirectoryInResources else { return [] }
        var datasets: [Dataset] = []
        for localURL in trainingDirectory.directoryContents {
            let folderName = localURL.lastPathComponent
            let dataset = Dataset(name: folderName,
                    type: .validation,
                    moves: moves,
                    resourceDirectory: localURL)
            datasets.append(dataset)
        }
        return datasets
    }

    // 获取本地验证数据集名称列表
    var localValidationDatasetNames: [String] {
        localValidationDatasets.map { $0.name }
    }

    // 获取有效的移动手势名称列表
    var moves: [String] {
        GameModel().validMoveNames.map { $0.capitalized }
    }

    // 重置所有训练相关状态
    func reset() {
        trainingMetrics = TrainingMetrics()
        currentTrainer?.cancel()  // 取消当前训练器
        currentTrainer = nil      // 清空训练器
        currentTrainingDataset = nil  // 清空训练数据集
        currentValidationDataset = nil  // 清空验证数据集
        completed = 0.0  // 重置完成进度
        currentPhase = ""  // 重置当前阶段
        currentState = .inactive  // 重置状态为未激活
    }
}
