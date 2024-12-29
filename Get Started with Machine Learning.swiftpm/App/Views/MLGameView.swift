/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// MLGameView: 机器学习模式的游戏视图包装器
// 使用相机和机器学习模型来识别玩家的手势
struct MLGameView: View {
    @EnvironmentObject var appModel: AppModel

    // 创建视图主体
    var body: some View {
        // 使用isMLGame=true初始化RPSGameView
        RPSGameView(isMLGame: true)
            // 注入全局状态
            .environmentObject(appModel)
    }
}
