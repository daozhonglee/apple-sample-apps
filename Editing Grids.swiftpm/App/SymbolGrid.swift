/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

/// SymbolGrid 展示了以下 SwiftUI 核心概念：
/// 1. 网格布局 (LazyVGrid)
/// 2. 状态管理 (@State)
/// 3. 动画效果 (withAnimation)
/// 4. 导航和模态视图
/// 5. 工具栏定制
struct SymbolGrid: View {
    /// 控制模态视图显示的状态
    @State private var isAddingSymbol = false
    /// 控制编辑模式的状态
    @State private var isEditing = false

    /// 网格列数相关配置
    private static let initialColumns = 3
    @State private var selectedSymbol: Symbol?
    @State private var numColumns = initialColumns
    /// GridItem 数组用于定义网格布局
    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
    
    @State private var symbols = [
        Symbol(name: "tshirt"),
        Symbol(name: "eyes"),
        Symbol(name: "eyebrow"),
        Symbol(name: "nose"),
        Symbol(name: "mustache"),
        Symbol(name: "mouth"),
        Symbol(name: "eyeglasses"),
        Symbol(name: "facemask"),
        Symbol(name: "brain.head.profile"),
        Symbol(name: "brain"),
        Symbol(name: "icloud"),
        Symbol(name: "theatermasks.fill"),
    ]
    
    /// 计算属性：返回列数文本描述
    var columnsText: String {
        numColumns > 1 ? "\(numColumns) Columns" : "1 Column"
    }

    var body: some View {
        VStack {
            /// Stepper：编辑模式下的列数调节器
            if isEditing {
                Stepper(columnsText, value: $numColumns, in: 1...6, step: 1) { _ in
                    /// 使用动画效果更新网格列数
                    withAnimation { gridColumns = Array(repeating: GridItem(.flexible()), count: numColumns) }
                }
                .padding()
            }

            ScrollView {
                /// LazyVGrid：延迟加载的网格视图
                LazyVGrid(columns: gridColumns) {
                    /// ForEach：遍历符号数组创建网格项
                    ForEach(symbols) { symbol in
                        /// NavigationLink：导航到符号详情页
                        NavigationLink(destination: SymbolDetail(symbol: symbol)) {
                            /// ZStack：叠加布局，用于显示删除按钮
                            ZStack(alignment: .topTrailing) {
                                /// 符号图标显示
                                Image(systemName: symbol.name)
                                    .resizable()
                                    .scaledToFit()
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(.accentColor)
                                    .ignoresSafeArea(.container, edges: .bottom)
                                    .cornerRadius(8)
                                
                                /// 编辑模式下的删除按钮
                                if isEditing {
                                    Button {
                                        /// 删除操作
                                        guard let index = symbols.firstIndex(of: symbol) else { return }
                                        withAnimation {
                                            _ = symbols.remove(at: index)
                                        }
                                    } label: {
                                        Image(systemName: "xmark.square.fill")
                                            .font(.title)
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.white, Color.red)
                                    }
                                    .offset(x: 7, y: -7)
                                }
                            }
                            .padding()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        /// 导航栏配置
        .navigationTitle("My Symbols")
        .navigationBarTitleDisplayMode(.inline)
        /// 模态视图配置
        .sheet(isPresented: $isAddingSymbol, onDismiss: addSymbol) {
            SymbolPicker(symbol: $selectedSymbol)
        }
        /// 工具栏配置
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation { isEditing.toggle() }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isAddingSymbol = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(isEditing)
            }
        }

    }
    
    /// 添加新符号的方法
    func addSymbol() {
        guard let name = selectedSymbol else { return }
        withAnimation {
            symbols.insert(name, at: 0)
        }
    }
}

/// 预览提供器
struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolGrid()
    }
}
