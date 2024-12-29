/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// RPSGameView: 石头剪刀布游戏的主视图
// 负责展示游戏界面、处理游戏逻辑和用户交互
struct RPSGameView: View {
    // 应用全局状态
    @EnvironmentObject var appModel: AppModel
    // 游戏模型，负责管理游戏状态
    @StateObject var gameModel: GameModel = GameModel()

    // 是否为机器学习模式的游戏
    var isMLGame: Bool = false

    // 预测的移动和游戏结果文本
    @State private var predictedMove: String = GameMove.unknown.name
    @State private var gameResultText: String = ""

    // 根据游戏状态显示不同的标签文本
    private var label: String {
        switch gameModel.currentState {
        case .finished: return gameResultText.isEmpty ? "VS" : " "
        case .playing: return String(gameModel.countDown)
        case .notPlaying: return "VS"
        }
    }

    // 确定是否禁用播放按钮
    private var shouldDisablePlayButton: Bool {
        guard gameModel.currentState != .playing else { return true }
        if isMLGame {
            return !appModel.isHandInFrame || !appModel.isGatheringObservations || !gameResultText.isEmpty
        } else {
            return !gameResultText.isEmpty
        }
    }

    private let padding: CGFloat = 20

    var body: some View {
        // 创建主视图垂直布局
        VStack(spacing: 0) {
            // 显示电脑的移动
            computersMoveView()
            // 显示中央标签
            labelView()
            // 显示玩家的移动
            yourMoveView()

            // 非ML模式下显示播放按钮
            if !isMLGame {
                playButton()
                    .modifier(GameLabelBackground())
            }
        }
        // 监听游戏计时器更新
        .onReceive(gameModel.gameTimer) { _ in
            let resultText = gameModel.updateGameTimer()
            guard !resultText.isEmpty else { return }
            gameResultText = resultText
        }
        // 监听旋转计时器更新电脑移动
        .onReceive(gameModel.rotationTimer) { _ in
            gameModel.updateComputersMove()
        }
        // 设置游戏背景
        .background(gameBackground())
    }

    // 电脑移动的视图
    private func computersMoveView() -> some View {
        MoveView(player: .computer, moveName: $gameModel.computersMoveName)
            .environmentObject(gameModel)
            .frame(maxHeight: isMLGame ? 200 : .infinity, alignment: .center)
    }

    // 中央标签视图
    private func labelView() -> some View {
        Text(label)
            .font(.largeTitle)
            .foregroundColor(.labelAccent)
            .animation(.default)
            .transition(.slide)
            .padding(isMLGame ? padding / 2 : padding)
            .frame(maxWidth: .infinity)
            .modifier(GameLabelBackground())
    }

    // 游戏结果视图
    @ViewBuilder
    private func gameResultView() -> some View {
        if gameModel.currentState == .finished {
            Text(gameResultText)
                .font(.largeTitle)
                .foregroundColor(.labelAccent)
                .padding(padding)
                .modifier(GameLabelBackground())
                .cornerRadius(10.0)
                .opacity(gameResultText.isEmpty ? 0.0 : 1.0)
                .animation(.linear, value: gameResultText.isEmpty)
        }
    }

    // 玩家移动视图
    @ViewBuilder
    private func yourMoveView() -> some View {
        ZStack {
            if isMLGame {
                camera()
            } else {
                MoveView(player: .you, moveName: $gameModel.yourMoveName, hideArrows: shouldDisablePlayButton)
                    .environmentObject(gameModel)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .onChange(of: gameResultText) { _ in
                        guard !gameResultText.isEmpty else { return }
                        Task {
                            await Task.sleep(seconds: 1.5)
                            gameResultText = ""
                        }
                    }
            }
        }
        .overlay(alignment: .center) {
            gameResultView()
                .padding(.bottom, isMLGame ? padding * 2.5 : 0)
                .animation(.easeIn, value: !gameResultText.isEmpty)
        }
    }

    // 相机视图（用于ML模式）
    private func camera() -> some View {
        CameraView()
            .environmentObject(appModel)
            .onChange(of: gameModel.currentState) { _ in
                updateCameraAppearance(currentState: gameModel.currentState)
            }
            .onChange(of: appModel.predictionLabel) { _ in
                guard gameModel.currentState != .finished else { return }
                updateYourMove(with: appModel.predictionLabel)

            }
            .overlay(alignment: .bottom) {
                VStack {
                    PredictionLabelOverlay(label: appModel.predictionLabel)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    playButton()
                        .background(Color.translucentBlack)
                }
            }
    }

    // 播放按钮
    private func playButton() -> some View {
        Button {
            gameModel.updateGameState()
        } label: {
            Text(gameModel.playButtonText)
        }
        .buttonStyle(CapsuleButton(disabled: shouldDisablePlayButton))
        .disabled(shouldDisablePlayButton)
        .padding()
        .frame(maxWidth: .infinity)
    }

    // 游戏背景
    private func gameBackground() -> some View {
        Image("game-background")
            .resizable()
            .scaledToFill()
    }

    // 更新玩家移动
    private func updateYourMove(with predicationLabel: String) {
        guard !predicationLabel.isEmpty else {
            gameModel.yourMoveName = GameMove.unknown.name
            return
        }
        predictedMove = predicationLabel
        gameModel.yourMoveName = predictedMove
    }
    
    // 根据游戏状态更新相机外观
    private func updateCameraAppearance(currentState: GameState) {
        switch currentState {
        case .playing:
            appModel.shouldPauseCamera = true
        case .finished:
            appModel.isGatheringObservations = false
            Task {
                await Task.sleep(seconds: 1.5)
                gameResultText = ""
                appModel.shouldPauseCamera = false
                gameModel.currentState = .notPlaying
            }
        case .notPlaying:
            appModel.shouldPauseCamera = false
        }
    }
}

// 预览提供者
struct RPSGameView_Previews: PreviewProvider {
    static var previews: some View {
        // 创建预览视图
        RPSGameView()
            .environmentObject(AppModel())
    }
}
