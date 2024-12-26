/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

/// 符号选择器视图
/// 用于选择事件的图标和颜色
struct SymbolPicker: View {
    @Binding var event: Event            // 事件数据绑定
    @State private var selectedColor: Color = ColorOptions.default   // 当前选中的颜色
    @Environment(\.dismiss) private var dismiss    // 关闭视图的环境变量
    @State private var symbolNames = EventSymbols.symbolNames    // 可选择的符号列表
    @State private var searchInput = ""    // 搜索输入内容
    
    var columns = Array(repeating: GridItem(.flexible()), count: 6)    // 网格布局配置

    var body: some View {
        VStack {
            // 顶部完成按钮
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
                .padding()
            }
            // 当前选中的符号预览
            HStack {
                Image(systemName: event.symbol)
                    .font(.title)
                    .imageScale(.large)
                    .foregroundColor(selectedColor)

            }
            .padding()

            // 颜色选择器
            HStack {
                ForEach(ColorOptions.all, id: \.self) { color in
                    Button {
                        selectedColor = color
                        event.color = color
                    } label: {
                        Circle()
                            .foregroundColor(color)
                    }
                }
            }
            .padding(.horizontal)
            .frame(height: 40)

            Divider()

            // 符号网格选择器
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(symbolNames, id: \.self) { symbolItem in
                        Button {
                            event.symbol = symbolItem
                        } label: {
                            Image(systemName: symbolItem)
                                .sfSymbolStyling()
                                .foregroundColor(selectedColor)
                                .padding(5)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .drawingGroup()
            }
        }
        .onAppear {
            selectedColor = event.color
        }
    }
}

struct SFSymbolBrowser_Previews: PreviewProvider {
    static var previews: some View {
        SymbolPicker(event: .constant(Event.example))
    }
}
