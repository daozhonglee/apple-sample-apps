/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import Charts

// DebugModeView: 调试模式视图
// 显示实时预测数据和可视化信息
struct DebugModeView: View {
    @EnvironmentObject var appModel: AppModel

    // 获取实时预测数据
    private var livePredictionData: [PredictionMetric] {
        return appModel.predictionProbability.data
    }

    var body: some View {
        // 创建导航堆栈容器
        NavigationStack {
            // 创建垂直布局容器
            VStack(alignment: .center, spacing: 0) {
                // 显示带节点的相机视图
                CameraView(showNodes: true)
                    .environmentObject(appModel)
                    // 在右下角添加预测标签叠加
                    .overlay(alignment: .bottomTrailing) {
                        PredictionLabelOverlay(label: appModel.predictionLabel, showIcon: false)
                    }
                // 添加预测条形图
                predictionBarChart()
            }
            // 视图加载时查找现有模型
            .task {
                await appModel.findExistingModels()
            }
            // 添加工具栏
            .toolbar {
                availableMLModelsToolbarItem()
            }
        }
        // 设置强调色
        .accentColor(.accent)
    }

    // 预测概率条形图
    private func predictionBarChart() -> some View {
        VStack {
            Chart(livePredictionData, id: \.category) {
                BarMark(xStart: .value("zero", 0.0),
                        xEnd: .value("Probability", $0.value),
                        y: .value("Category", $0.category))
            }
            .chartXScale(domain: 0...1)
            .chartXAxisLabel("Confidence")
            .chartXAxis(.visible)
            .chartYAxis(.visible)
            .animation(.easeIn, value: livePredictionData)
            .foregroundColor(.accent)
        }
        .modifier(ChartViewStyle())
    }

    // 可用ML模型的工具栏项
    private func availableMLModelsToolbarItem() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
                MLModelListView()
                    .environmentObject(appModel)
            } label: {
                Text("ML Models")
            }
        }
    }
}

struct DebugModeView_Previews: PreviewProvider {
    static var previews: some View {
        DebugModeView()
            .environmentObject(AppModel())
    }
}
