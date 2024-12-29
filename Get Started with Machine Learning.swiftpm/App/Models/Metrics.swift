/*
See the License.txt file for this sample’s licensing information.
*/

import Foundation
import CreateML

// 训练指标结构体，用于记录训练过程中的数据点
struct TrainingMetric: Identifiable {
    // 使用 x 值作为唯一标识符
    var id: Double { x }
    // X轴值（如训练轮次）
    let x: Double
    // Y轴值（如准确率或损失值）
    let y: Double
}

// 训练指标管理类
class TrainingMetrics: ObservableObject {
    // 所有指标类型列表
    var allMetricTypes = [String]()
    // 存储不同类型指标的数据字典
    var data: [String: [TrainingMetric]] = [:]
    
    init() {}
    
    // 为特定类型添加数据点
    func addDatapointForType(type: String, x: Double, y: Double) {
        let metric = TrainingMetric(x: x, y: y)
        if var currentMetricArray = data[type] {
            // 如果已存在该类型，追加数据
            currentMetricArray.append(metric)
            data[type] = currentMetricArray
        } else {
            // 如果是新类型，创建新数组
            allMetricTypes.append(type)
            data[type] = [metric]
        }
    }
}

// 预测指标结构体
struct PredictionMetric: Identifiable {
    // 使用类别作为唯一标识符
    var id: String { category }
    // 预测类别
    let category: String
    // 预测值（概率）
    let value: Double
}

// 预测指标相等性比较扩展
extension PredictionMetric: Equatable {
    static func == (lhs: PredictionMetric, rhs: PredictionMetric) -> Bool {
        return lhs.id == rhs.id &&
               lhs.category == rhs.category &&
               lhs.value == rhs.value
    }
}

// 预测指标管理类
class PredictionMetrics: ObservableObject, Identifiable {
    // 预测指标数组
    var data = [PredictionMetric]()
    // 预测概率字典
    var dictionary: [String : Double] = [:]
    
    init() {}
    
    // 更新预测数据
    func getNewPredictions(from probabilities: [String: Double]) {
        var tempData = [PredictionMetric]()
        dictionary = probabilities
        
        // 将概率字典转换为指标数组
        _ = dictionary.map { (key: String, value: Double) in
            tempData.append(PredictionMetric(category: key, value: value))
        }
        // 按类别排序
        data = tempData.sorted(by: { $0.category > $1.category })
    }
}
