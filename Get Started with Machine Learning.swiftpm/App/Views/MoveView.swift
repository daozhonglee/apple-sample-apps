/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// MoveView: 显示玩家或电脑的移动选择
// 包含石头、剪刀、布的图标显示和选择功能
struct MoveView: View {
    // 表示当前视图是为玩家还是电脑
    var player: Player

    @EnvironmentObject var gameModel: GameModel
    // 绑定当前选择的移动名称
    @Binding var moveName: String

    // 是否隐藏箭头按钮
    var hideArrows: Bool = true

    // 当前选择的移动
    @State private var currentMove: GameMove = GameMove.unknown

    // UI尺寸相关的变量
    @ScaledMetric private var iconPadding: CGFloat = 20
    @ScaledMetric private var viewPadding: CGFloat = 5
    @ScaledMetric private var scaledPadding: CGFloat = 20
    @ScaledMetric private var fontSize: CGFloat = 90
    @ScaledMetric private var arrowFontSize: CGFloat = 55
    @ScaledMetric private var cornerRadius: CGFloat = 15

    // 是否显示选择箭头（只在玩家视图显示）
    private var shouldShowArrows: Bool {
        player == .you
    }

    var body: some View {
        HStack {
            if shouldShowArrows {
                Button {
                    // 向后切换移动选择
                    updateMove(.backward)
                } label : {
                    // 创建后退箭头标签
                    Label("Back", systemImage: "arrowshape.left.fill")
                        // 设置箭头大小
                        .font(.system(size: arrowFontSize))
                }
                // 使用朴素按钮样式
                .buttonStyle(.plain)
                // 只显示图标
                .labelStyle(.iconOnly)
                // 设置箭头颜色
                .foregroundColor(.white)
                // 根据hideArrows状态控制透明度
                .opacity(hideArrows ? 0.0 : 1.0)
                // 添加渐变动画
                .animation(.linear, value: hideArrows)
            }

            shape()
                .overlay(alignment: .center) {
                    icon()
                }
                .padding(viewPadding)
            
            if shouldShowArrows {
                Button {
                    updateMove()
                } label : {
                    Label("Next", systemImage: "arrowshape.right.fill")
                        .font(.system(size: arrowFontSize))
                }
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .foregroundColor(.white)
                .opacity(hideArrows ? 0.0 : 1.0)
                .animation(.linear, value: hideArrows)

            }
        }
        // 监听移动名称变化
        .onChange(of: moveName) { _ in
            // 更新当前移动状态
            currentMove = gameModel.validMoves[moveName] ?? GameMove.unknown
        }
        // 添加内边距
        .padding()
    }

    // 移动图标的背景形状
    private func shape() -> some View {
        Group {
            if shouldShowArrows {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.white)
                    .aspectRatio(contentMode: .fit)
            } else {
                Circle()
                    .fill(.white)
            }
        }
        .shadow(color: .translucentBlack, radius: 3.0)
    }
    
    // 移动图标
    private func icon() -> some View {
        Group {
            if currentMove == GameMove.unknown {
                Image(systemName: currentMove.icon)
                    .foregroundColor(.labelAccent)
            } else {
                Text(currentMove.icon)
            }
        }
        .fixedSize()
        .font(.system(size: fontSize))
        .padding(iconPadding)
    }

    // 更新移动选择
    private func updateMove(_ direction: RotationDirection = .forward) {
        guard player == .you else { return }
        let newMove = gameModel.rotateThroughValidMoves(currentMove.name, direction: direction)
        gameModel.yourMoveName = newMove.name
    }
}
