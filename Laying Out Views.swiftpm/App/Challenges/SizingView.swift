/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
struct SizingView: View {
    var body: some View {
        VStack {
            ZStack {
                //由于所有视图都是唯一的，因此不同类型的视图在容器内有其自己的空间要求。这就是为什么矩形视图会调整它占用的空间，但文本和图像只占用它们需要的空间。
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.paleOrange)
                    //您可以指定哪个视图需要占用更多空间
                    //为宽度和高度提供固定值会限制视图的自适应程度,更好的方法是为视图提供最大、最小或理想的宽度和高度。这允许视图根据容器中的可用空间根据需要调整大小。
                    .frame(maxWidth: 200, maxHeight: 150)
                VStack {
                    Text("Roses are red,")
                    Image("Rose")
                        .resizable()
                        .scaledToFit()
                    //通常，您需要为图像添加尺寸限制，因为它们可能非常大。
                        .frame(maxWidth: 50)
                        .foregroundColor(.themeRed)
                    Text("violets are blue, ")
                }
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.paleOrange)
                    .frame(maxWidth: 200, maxHeight: 150)
                VStack {
                    Text("I just love")
                    Image("Heart")
                    // 当您在图像上使用帧修改器时，如果您首先使用 .ressized 修改器来指示您希望图像在其帧更改时调整大小，则它只会影响显示图像的大小。
                        .resizable()
                    //即使添加了理想的宽度和高度，向图像添加 frame 有时也会导致图像看起来被拉伸。对于图像，通常最好使用scaledToFill() 而不是 frame()
                        .scaledToFit()
                        .frame(maxWidth: 50)
                        .foregroundColor(.themeRed)
                    //如果将 frame 添加到文本视图，视图内的实际文本不会改变 - 它会使包含文本的视图更大。这允许更多文本适合视图。
                    Text("coding with you!")
                }
            }
        }
        .font(.headline)
        .foregroundColor(.darkBrown)
    }
}

struct SizingView_Previews: PreviewProvider {
    static var previews: some View {
        SizingView()
    }
}
