/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct DetailView: View {
    let item: Item

    var body: some View {
        // AsyncImage 异步加载大图
        AsyncImage(url: item.url) { image in
            // scaledToFit 保持图片比例适应屏幕
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        if let url = Bundle.main.url(forResource: "mushy1", withExtension: "jpg") {
            DetailView(item: Item(url: url))
        }
    }
}
