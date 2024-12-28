/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// 在 SwiftUI 中指定对齐方式有多种方法。一种方法是指定 HStack、VStack 或 ZStack 内部的对齐方式。 VStack的默认对齐方式是居中。
struct AmazingAlignment: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 40))
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 10)
            VStack (alignment: .trailing){
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 40))
                    
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 10)
            }
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 40))
                .frame(maxWidth: .infinity, alignment: .trailing)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 10)
            HStack(spacing: 20) {
                //在 HStack 内添加 Spacer 会导致堆栈扩展以填充任何剩余的水平空间，并将 Image 视图推到 .trailing 边缘。
                //Spacer仅填充HStack中的空白空间。相反，如果没有可用的空间用于间隔器，则它将不会渲染。
                Spacer()
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 40))
                    .background(Color.yellow)
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 40))
                    //您还可以向图像视图的后缘添加填充，以将其放置在距边缘更远的位置。
                    .padding(.trailing, 20)
            }
            .background(Color.mint)
            Rectangle()
//            通过将 maxWidth 设置为 .infinity，您可以水平拉伸图像视图，直到它填满剩余空间。将对齐参数设置为 .trailing 会使框架内容与 .trailing 边缘对齐。
                .frame(maxWidth: .infinity, maxHeight: 10)
        }
        //通过将 padding 修改器应用到 VStack，您只需添加一次，而不必将其添加到 VStack 内的每个子视图。
        .padding(.horizontal)
        //，如果您希望书架具有特定的宽度，请使用frame 而不是 padding
        .frame(width: 250)
        //在框架后添加边框有助于使框架可视化。
        .border(Color.black)
    }
}

struct AmazingAlignment_Previews: PreviewProvider {
    static var previews: some View {
        AmazingAlignment()
    }
}
