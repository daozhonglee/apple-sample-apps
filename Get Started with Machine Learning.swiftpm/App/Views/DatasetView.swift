/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// DatasetView: 训练数据集管理视图
// 用于查看和管理机器学习模型的训练数据集
struct DatasetView: View {

    @EnvironmentObject var appModel: AppModel
    // 训练数据模型
    @StateObject var trainerDataModel = TrainerDataModel()

    // 本地和新创建的数据集
    @State private var localDatasets: [Dataset] = []
    @State private var newDatasets: [Dataset] = []
    @State private var datasetName: String = ""
    @FocusState private var focusField: Bool

    // 所有数据集的名称
    private var allDatasetNames: [String] {
        localDatasets.map { $0.name } + newDatasets.map { $0.name }
    }

    var body: some View {
        // 创建导航堆栈容器
        NavigationStack {
            // 创建可滚动视图
            ScrollView {
                // 创建垂直布局容器
                VStack(spacing: 20) {
                    // 显示本地数据集列表
                    ForEach(localDatasets) { dataset in
                        datasetCell(dataset)
                    }
                    // 显示新创建的数据集列表
                    ForEach(newDatasets) { dataset in
                        datasetCell(dataset)
                    }
                }
                // 添加内边距
                .padding()
            }
            // 添加工具栏
            .toolbar {
                addDatasetToolbarItem()
            }
            // 设置导航标题
            .navigationTitle("Training Datasets")
            // 设置导航标题显示模式
            .navigationBarTitleDisplayMode(.inline)
        }
        // 设置强调色
        .accentColor(.accent)
        // 视图出现时加载本地数据集
        .onAppear {
            localDatasets = getLocalDatasets()
        }
    }

    // 数据集单元格视图
    private func datasetCell(_ dataset: Dataset) -> some View {
        TrainingDatasetCell(trainerDataModel: trainerDataModel, dataset: dataset)
            .environmentObject(appModel)
    }

    // 添加数据集的工具栏按钮
    private func addDatasetToolbarItem() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
                TrainingView(trainerDataModel: trainerDataModel, newDatasets: $newDatasets)
                    .environmentObject(appModel)
                    .onAppear {
                        let newDataset = Dataset(type: .training, moves: trainerDataModel.moves, isNew: true)
                        trainerDataModel.currentTrainingDataset = newDataset
                    }
            } label: {
                Label("Create a new dataset", systemImage: "plus")
                    .labelStyle(.iconOnly)

            }
        }
    }
    
    // 获取本地数据集
    private func getLocalDatasets() -> [Dataset] {
        return trainerDataModel.localTrainingDatasets
    }
}

struct DatasetView_Previews: PreviewProvider {
    static var previews: some View {
        DatasetView()
            .environmentObject(AppModel())
    }
}
