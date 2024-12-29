/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

final class GameModel: ObservableObject {
    // 默认倒计时时间
    static var countDown: Int = 3
    // 游戏主计时器，每秒触发一次
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    // 旋转计时器，每0.15秒触发一次
    let rotationTimer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()

    // 播放按钮文本
    var playButtonText: String = "Play"
    // 有效移动的字典
    var validMoves: [String: GameMove] = [:]
    // 有效移动名称的列表
    lazy var validMoveNames: [String] = {
        return validMoves.values.map { $0.name }
    }()

    // 倒计时值
    @Published var countDown: Int = GameModel.countDown
    // 当前游戏状态
    @Published var currentState: GameState = .notPlaying
    // 玩家的移动名称
    @Published var yourMoveName: String = GameMove.unknown.name
    // 电脑的移动名称
    @Published var computersMoveName: String = GameMove.unknown.name

    // 获取玩家的移动对象
    private var yourMove: GameMove {
        validMoves[yourMoveName] ?? GameMove.unknown
    }
    
    // 获取电脑的移动对象
    private var computersMove: GameMove {
        validMoves[computersMoveName] ?? GameMove.unknown
    }

    // 初始化游戏模型
    init() {
        // 创建石头剪刀布的移动对象
        let rock = GameMove(name: "rock", icon: "✊")
        let paper = GameMove(name: "paper", icon: "✋")
        let scissors = GameMove(name: "scissors", icon: "✌️")

        // 设置胜负关系
        rock.beats([scissors])
        paper.beats([rock])
        scissors.beats([paper])

        // 添加到有效移动字典
        validMoves[rock.name] = rock
        validMoves[paper.name] = paper
        validMoves[scissors.name] = scissors
    }

    // 更新游戏状态
    func updateGameState() {
        switch currentState {
        case .notPlaying:
            currentState = .playing  // 从未开始状态切换到游戏中
        case .playing:
            currentState = .notPlaying  // 从游戏中切换到未开始
        case .finished:
            currentState = .playing  // 从结束状态重新开始游戏
        }
    }

    // 更新电脑的移动选择
    func updateComputersMove() {
        guard currentState == .playing else { return }
        // 轮转到下一个有效移动
        let nextMove = rotateThroughValidMoves(computersMoveName)
        computersMoveName = nextMove.name
    }
    
    // 获取游戏结果文本
    func updateGameResultText() -> String {
        var text = ""
        
        guard currentState == .finished else { return text }

        let result = getGameResult()
        
        // 根据结果返回对应文本
        switch result {
        case .win: text = "YOU WIN"          // 玩家获胜
        case .lose: text = "YOU LOSE"        // 玩家失败
        case .tie: text = "TIE"              // 平局
        case .inconclusive: text = "INCONCLUSIVE"  // 未决定
        }

        return text
    }

    // 更新游戏计时器
    func updateGameTimer() -> String {
        switch currentState {
        case .playing:
            if countDown > 0 {
               countDown -= 1  // 倒计时减一
            }
            if countDown == 0 {
                currentState = .finished      // 倒计时结束，游戏结束
                countDown = GameModel.countDown  // 重置倒计时
                playButtonText = "Play Again"    // 更新按钮文本
            }
            return updateGameResultText()
        case .finished, .notPlaying:
            return ""
        }
    }

    // 在有效移动之间轮转
    func rotateThroughValidMoves(_ currentMove: String, direction: RotationDirection = .forward) -> GameMove {
        // 获取第一个和最后一个有效移动
        guard let firstMoveName = validMoveNames.first,
              let firstMove = validMoves[firstMoveName],
              let lastMoveName = validMoveNames.last,
              let lastMove = validMoves[lastMoveName] else {
            return GameMove.unknown            
        }
        
        // 获取当前移动的索引
        guard let index = validMoveNames.firstIndex(of: currentMove) else { return firstMove }
        switch direction {
        case .forward:  // 向前轮转
            if index + 1 < validMoveNames.count {
                let moveName = validMoveNames[index + 1]
                return validMoves[moveName] ?? firstMove
            } else {
                return firstMove  // 回到第一个移动
            }
        case .backward:  // 向后轮转
            if index - 1 >= 0 {
                let moveName = validMoveNames[index - 1]
                return validMoves[moveName] ?? lastMove
            } else {
                return lastMove  // 回到最后一个移动
            }
        }
    }
    
    // 获取游戏结果
    private func getGameResult() -> GameResult {
        // 确保双方都有有效的移动
        guard yourMove != GameMove.unknown,
              computersMove != GameMove.unknown else {
            return .inconclusive
        }

        return yourMove.compare(to: computersMove)
    }
}

// 游戏状态枚举
enum GameState: String {
    case notPlaying  // 未开始游戏
    case playing     // 游戏进行中
    case finished    // 游戏结束
}

// 游戏结果枚举
enum GameResult {
    case tie          // 平局
    case win          // 胜利
    case lose         // 失败
    case inconclusive // 未决定
}

// 轮转方向枚举
enum RotationDirection {
    case forward   // 向前
    case backward  // 向后
}
