/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct CameraView: View {
    // 环境对象，用于访问应用的主要模型
    @EnvironmentObject var appModel: AppModel
    // 是否显示手部关键点节点
    var showNodes: Bool = false

    // 计算属性：当有图像且有模型但没检测到手时显示警告
    private var showWarning: Bool {
        appModel.viewfinderImage != nil && appModel.currentMLModel != nil && !appModel.isHandInFrame
    }

    // 获取预览图像尺寸
    private var previewImageSize: CGSize {
        appModel.camera.previewImageSize
    }

    // 获取手部关节点坐标
    private var handJointPoints: [CGPoint] {
        appModel.nodePoints
    }

    var body: some View {
        // 取景器视图
        ViewfinderView(image: $appModel.viewfinderImage)
            .overlay(alignment: .center)  {
                // 显示手部关键点覆盖层
                if showNodes {
                    HandPoseNodeOverlay(size: previewImageSize,
                                        points: handJointPoints)
                }
            }
            .overlay(alignment: .center) {
                // 显示相机框架覆盖层
                if showWarning {
                    CameraFrameOverlay()
                        .animation(.default, value: appModel.isHandInFrame)
                }
            }
            // 启动相机
            .task {
                await appModel.camera.start()
            }
            // 接收预测定时器事件
            .onReceive(appModel.predictionTimer) { _ in
                guard appModel.currentMLModel != nil else { return }
                appModel.canPredict = true
            }
            // 视图消失时停止预测
            .onDisappear {
                appModel.canPredict = false
            }
    }
}

// 预览提供者
struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(showNodes: true)
            .environmentObject(AppModel())
    }
}
