/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// FavoritesView 展示用户的爱好、喜欢的食物和颜色
struct FavoritesView: View {
    var body: some View {
        VStack {
            Text("Favorites")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)
            
            Text("Hobbies")
                .font(.title2)
            
            // 水平排列爱好图标
            HStack {
                // ForEach 使用迭代对应数组。因为 ForEach 需要知道如何区分各个项目，所以您将 \.self 作为参数传递给 id。
                ForEach(information.hobbies, id: \.self) { hobby in
                    Image(systemName: hobby)
                        .resizable()            // 允许图标大小可调整
                        .frame(maxWidth: 80, maxHeight: 60)  // 设置图标最大尺寸
                }
                .padding()
            }
            .padding()

            Text("Foods")
                .font(.title2)
            
            HStack(spacing: 60) {
                ForEach(information.foods, id: \.self) { food in
                    Text(food)
                        .font(.system(size: 48))  // 设置emoji大小
                }
            }
            .padding()

            // 颜色部分
            Text("Favorite Colors")
                .font(.title2)

            HStack(spacing: 30) {
                ForEach(information.colors, id: \.self) { color in
                    color
                        .frame(width: 70, height: 70)  // 设置颜色方块大小
                        .cornerRadius(10)               // 添加圆角
                }
            }
            .padding()
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
