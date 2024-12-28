/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

//了解如何使用一系列 SwiftUI 内置视图和组合视图组合网格视图。

struct GridView: View {
    // 使用 @EnvironmentObject 接收共享的数据模型
    @EnvironmentObject var dataModel: DataModel

    // @State 用于管理视图的本地状态
    @State private var isAddingPhoto = false
    @State private var isEditing = false

    private static let initialColumns = 3
    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
    @State private var numColumns = initialColumns
    
    private var columnsTitle: String {
        gridColumns.count > 1 ? "\(gridColumns.count) Columns" : "1 Column"
    }
    
    var body: some View {
        VStack {
            if isEditing {
                ColumnStepper(title: columnsTitle, range: 1...8, columns: $gridColumns)
                .padding()
            }
            //ScrollView 允许网格的内容在必要时垂直滚动。
            ScrollView {
                // LazyVGrid 用于创建网格布局
                LazyVGrid(columns: gridColumns) {
                    // ForEach 遍历并显示所有图片项， 由于每个项目实例都是可识别的，因此在创建网格视图时不需要 id 参数
                    ForEach(dataModel.items) { item in
                        //GeometryReader 是 SwiftUI 中的一个视图容器，用于获取其父视图或自身的大小和位置信息。它允许你根据视图的几何信息（如尺寸、坐标等）动态调整子视图的布局或行为。
                        // 这里使用主要是为了获取父视图提供的空间大小，以便在 GridItemView 中使用， 否则 GridItemView 的 size 就得硬编码，不能使用不同屏幕尺寸
                        GeometryReader { geo in
                            NavigationLink(destination: DetailView(item: item)) {
                                GridItemView(size: geo.size.width, item: item)
                            }
                        }
                        .cornerRadius(8.0)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(alignment: .topTrailing) { // // 在右上角添加叠加层
                            if isEditing { // / 仅在编辑模式显示
                                Button {
                                    withAnimation {
                                        dataModel.removeItem(item)
                                    }
                                } label: {
                                    Image(systemName: "xmark.square.fill")
                                                .font(Font.title)  // 设置图标大小
                                                .symbolRenderingMode(.palette) // 启用多色模式
                                                .foregroundStyle(.white, .red) // 设置图标颜色：白色X，红色背景
                                }
                                .offset(x: 7, y: -7)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        // .sheet 用于显示模态视图
        .sheet(isPresented: $isAddingPhoto) {
            PhotoPicker()
        }
        // 工具栏配置
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation { isEditing.toggle() }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isAddingPhoto = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(isEditing) // // 编辑模式下禁用编辑
            }
        }
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView().environmentObject(DataModel())
            .previewDevice("iPad (8th generation)")
    }
}

