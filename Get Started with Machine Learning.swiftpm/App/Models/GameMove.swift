/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

final class GameMove {
    // 未知移动的默认实例
    static var unknown = GameMove(name: "unknown", icon: "questionmark")
    // 移动的名称
    var name: String
    // 移动的图标
    var icon: String
    // 可以击败的其他移动列表
    var beatsMoves: [GameMove] = []

    // 初始化方法
    init(name: String, icon: String) {
        self.name = name.capitalized
        self.icon = icon
    }
    
    // 添加可以击败的移动
    func beats(_ moves: [GameMove]) {
        beatsMoves += moves
    }
    
    // 判断是否能击败指定的移动
    func isWinner(comparedTo move: GameMove) -> Bool {
        return beatsMoves.contains { $0 == move }
    }

    // 与其他移动比较并返回游戏结果
    func compare(to move: GameMove) -> GameResult {
        if isWinner(comparedTo: move) {
            return .win
        } else if move.isWinner(comparedTo: self) {
            return .lose
        }
        return .tie
    }
}

extension GameMove: Equatable {
    static func == (lhs: GameMove, rhs: GameMove) -> Bool {
        return lhs.name == rhs.name &&
               lhs.icon == rhs.icon &&
               lhs.beatsMoves == rhs.beatsMoves
    }
}

enum Player {
    case you
    case computer
}
