/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct HalfCard: View {
    var body: some View {
        VStack {
//            Spacer()
            Image(systemName: "crown.fill")
                .font(.system(size: 80))
        }
        //#-learning-code-snippet(6.debugFrameCorrection)
        //overlay 修饰符允许您在视图上添加叠加视图。这些叠加视图位于视图的顶部，并且不会影响视图的布局。
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay (alignment: .topLeading) {
            VStack {
                Image(systemName: "crown.fill")
                    .font(.body)
                Text("Q")
                    .font(.largeTitle)
                Image(systemName: "heart.fill")
                    .font(.title)
            }
            .padding()
        }
        //向视图添加边框是一个很好的调试工具，因为它允许您查看视图占用了多少空间。您可以使用此技术来诊断代码中的许多问题。
        //为什么在frame之前或之后应用边框会有所不同？这是因为每次应用修改器时实际上都会生成一个新视图，因此应用它们的顺序非常重要。
        .border(Color.blue)
        .border(Color.green)
        //#-learning-code-snippet(6.debugFrameQuestion)
        //#-learning-code-snippet(6.debugFrame)
//        #-learning-code-snippet(6.debugBorder)
    }
}

struct DebuggingView: View {
    var body: some View {
        VStack {
            HalfCard()
            HalfCard()
                .rotationEffect(.degrees(180))
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black)
        )
        .aspectRatio(0.70, contentMode: .fit)
        .foregroundColor(.red)
        .padding()
    }
}

struct DebuggingView_Previews: PreviewProvider {
    static var previews: some View {
        DebuggingView()
    }
}
