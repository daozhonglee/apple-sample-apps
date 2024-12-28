/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// Sendable 协议表示这个类型可以安全地在并发环境中使用
struct MemeCreator: View, Sendable {
    // @EnvironmentObject 从视图环境中获取数据
    // 这允许在视图层次结构中向下传递数据
    @EnvironmentObject var fetcher: PandaCollectionFetcher
    
    // @State 用于管理视图的本地状态
    // 当这些值改变时，视图会自动重新渲染
    @State private var memeText = ""          // 梗图文本内容
    @State private var textSize = 60.0        // 文本大小
    @State private var textColor = Color.white // 文本颜色

    // @FocusState 用于管理键盘输入焦点
    // 可以通过这个状态编程式地控制键盘的显示和隐藏
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            LoadableImage(imageMetadata: fetcher.currentPanda)
                // overlay 修饰符在图片上覆盖文本输入框
                // alignment: .bottom 将文本框放置在底部
                .overlay(alignment: .bottom) {
                    TextField(
                        "Meme Text",
                        text: $memeText,      // $ 符号创建双向绑定
                        prompt: Text("")      // 占位符文本
                    )
                    .focused($isFocused)
                    .font(.system(size: textSize, weight: .heavy))
                    .shadow(radius: 10)
                    .foregroundColor(textColor)
                    .padding()
                    .multilineTextAlignment(.center)
                }
                .frame(minHeight: 150)

            Spacer()
            
            // 条件视图：只有在有文本输入时才显示控制面板
            if !memeText.isEmpty {
                VStack {
                    HStack {
                        Text("Font Size")
                            .fontWeight(.semibold)
                        Slider(value: $textSize, in: 20...140)
                    }
                    
                    HStack {
                        Text("Font Color")
                            .fontWeight(.semibold)
                        ColorPicker("Font Color", selection: $textColor)
                            .labelsHidden()
                            .frame(width: 124, height: 23, alignment: .leading)
                        Spacer()
                    }
                }
                .padding(.vertical)
                .frame(maxWidth: 325)
                
            }

            // 底部按钮区域
            HStack {
                // 随机切换图片的按钮
                Button {
                    // randomElement() 从数组中随机选择一个元素
                    if let randomImage = fetcher.imageData.sample.randomElement() {
                        fetcher.currentPanda = randomImage
                    }
                } label: {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                            .padding(.bottom, 4)
                        Text("Shuffle Photo")
                    }
                    .frame(maxWidth: 180, maxHeight: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                // 添加文本的按钮
                Button {
                    // 激活文本输入框的焦点，弹出键盘
                    isFocused = true
                } label: {
                    VStack {
                        Image(systemName: "textformat")
                            .font(.largeTitle)
                            .padding(.bottom, 4)
                        Text("Add Text")
                    }
                    .frame(maxWidth: 180, maxHeight: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxHeight: 180, alignment: .center)
        }
        .padding()
        // task修饰符在视图加载时执行异步操作
        // try? 表示忽略可能的错误
        .task {
            try? await fetcher.fetchData()
        }
        .navigationTitle("Meme Creator")
    }
}
