/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct SymbolPicker: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var symbol: Symbol?

    let columns = Array(repeating: GridItem(.flexible()), count: 4)

    let pickableSymbols = [
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
		Symbol(name: "house.fill"),
		Symbol(name: "sun.max.fill"),
		Symbol(name: "cloud.rain.fill"),
		Symbol(name: "pawprint.fill"),
		Symbol(name: "lungs.fill"),
		Symbol(name: "face.smiling"),
		Symbol(name: "gear"),
		Symbol(name: "allergens"),
		Symbol(name: "bolt.heart"),
		Symbol(name: "ladybug.fill"),
		Symbol(name: "bus.fill"),
		Symbol(name: "bicycle.circle"),
		Symbol(name: "faceid"),
		Symbol(name: "gamecontroller.fill"),
		Symbol(name: "timer"),
		Symbol(name: "eye.fill"),
		Symbol(name: "person.icloud"),
		Symbol(name: "tortoise.fill"),
		Symbol(name: "hare.fill"),
		Symbol(name: "leaf.fill"),
		Symbol(name: "wand.and.stars"),
		Symbol(name:"globe.americas.fill"),
		Symbol(name: "globe.europe.africa.fill"),
		Symbol(name: "globe.asia.australia.fill"),
		Symbol(name: "hands.sparkles.fill"),
		Symbol(name: "hand.draw.fill"),
		Symbol(name: "waveform.path.ecg.rectangle.fill"),
		Symbol(name: "gyroscope"),
        
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(pickableSymbols) { symbol in
                    Button {
                        self.symbol = symbol
						//  SwiftUI 中用于关闭/退出当前视图的标准方法。
						//presentationMode - 这是一个环境值（Environment Value），通常通过 @Environment(\.presentationMode) 绑定获取
						// wrappedValue - 用于访问 Binding 类型的实际值
						// dismiss() - 触发视图的关闭操作
                        presentationMode.wrappedValue.dismiss()
                    } label: {
						Image(systemName: symbol.name)
                            .resizable()
                            .scaledToFit()
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.accentColor)
                            .ignoresSafeArea(.container, edges: .bottom)
                    }
                    .padding()
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct SymbolPicker_Previews: PreviewProvider {
    static var previews: some View {
        SymbolPicker(symbol: .constant(nil))
    }
}
