/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// CardView: 卡片内容的容器视图
struct CardView: View {
    @Binding var cardData: CardData    // 卡片数据
    var isEditing: Bool               // 是否处于编辑状态
    var fontStyle: JournalFont        // 字体样式
    
    var body: some View {
        // 根据卡片类型显示不同的内容视图
        switch cardData.card {
        case .mood(let value):         // 心情卡片
            MoodView(value: Binding<String>( get: { value }, set: { cardData.card = .mood(value: $0) } ), isEditing: isEditing, fontStyle: fontStyle, size: cardData.size)
        case .sleep(let value):        // 睡眠卡片
            SleepView(value: Binding<Double>( get: { value }, set: { cardData.card = .sleep(value: $0) } ), isEditing: isEditing, fontStyle: fontStyle, size: cardData.size)
        case .sketch(let value):       // 涂鸦卡片
            SketchView(value: Binding<[Line]>( get: { value }, set: { cardData.card = .sketch(value: $0) } ), isEditing: isEditing, fontStyle: fontStyle, size: cardData.size)
        case .photo(let value):        // 照片卡片
            PhotoView(value: Binding<ImageModel>( get: { value }, set: { cardData.card = .photo(value: $0) } ), isEditing: isEditing, fontStyle: fontStyle)
        case .text(let value):         // 文本卡片
            TextView(value: Binding<TextData>( get: { value }, set: { cardData.card = .text(value: $0) } ), isEditing: isEditing, fontStyle: fontStyle)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(cardData: .constant(CardData(card: .mood(value: "😢"))), isEditing: true, fontStyle: .font1)
            .background(CardBackground())
    }
}
