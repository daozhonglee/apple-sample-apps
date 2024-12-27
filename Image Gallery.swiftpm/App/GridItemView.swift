/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct GridItemView: View {
    let size: Double
    let item: Item

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // AsyncImage 用于异步加载和显示图片
            AsyncImage(url: item.url) { image in
                // 图片加载成功后的显示配置
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                // 加载过程中显示进度指示器
                ProgressView()
            }
            .frame(width: size, height: size)
        }
    }
}

struct GridItemView_Previews: PreviewProvider {
    static var previews: some View {
        if let url = Bundle.main.url(forResource: "mushy1", withExtension: "jpg") {
            GridItemView(size: 50, item: Item(url: url))
        }
    }
}
