/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct MoodViewFull: View {
    @Binding var value: String
    var isEditing: Bool
    var fontStyle: JournalFont
    let displayEmojis = 3
    private let emojis = ["😢", "😴", "😁", "😡", "😐"]
    
    var body: some View {
        VStack {
            Text(isEditing ? "What's your mood?" : "Mood")
                .foregroundColor(.darkBrown)
                .font(fontStyle.uiFont(15))
                //maxWidth 为 .infinity 的 .frame 修饰符会水平拉伸文本视图并填充可用空间。对齐参数可确保框架内的任何内容都与前缘对齐。
                .frame(maxWidth: .infinity, alignment: isEditing ? .leading : .center)


            HStack {
                if isEditing {
                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            value = emoji
                        } label: {
                            VStack {
                                Text(emoji)
                                    .font(.system(size: 35))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom)
                                Image(systemName: value == emoji ? "circle.fill" : "circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(.darkBrown)
                            }
                        }
                    }
                } else {
                    ForEach(0..<displayEmojis, id:\.self) { index in
                        Text(value)
                            .font(.system(size: 50))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            //通过将最大高度设置为 .infinity 将卡片标题推到边缘。
            .frame(maxHeight: .infinity, alignment: .center)
        }
        //设置 minHeight 和 maxHeight 允许视图针对不同的屏幕尺寸进行缩放。
        .frame(minHeight: 100, maxHeight: 200)
        .padding()
    }
}

struct MoodViewFull_Previews : PreviewProvider {
    static var previews: some View {
        MoodViewFullPreview()
    }
}
