/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

/// 相机界面视图
/// 负责展示相机预览和控制按钮
struct CameraView: View {
    // 相机数据模型，使用 @StateObject 确保视图生命周期内只创建一次
    @StateObject private var model = DataModel()
 
    // 定义顶部和底部控制栏的高度比例
    private static let barHeightFactor = 0.15
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                // 取景器视图，用于显示相机实时预览
                ViewfinderView(image: $model.viewfinderImage)
                    .overlay(alignment: .top) {
                        // 顶部控制栏背景
                        Color.black
                            .opacity(0.75) // 半透明效果
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                    }
                    .overlay(alignment: .bottom) {
                        // 底部控制栏，包含主要操作按钮
                        buttonsView()
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                            .background(.black.opacity(0.75))
                    }
                    .overlay(alignment: .center)  {
                        // 中央取景区域
                        // 使用透明视图标记取景区域，支持无障碍访问
                        Color.clear
                            .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                            .accessibilityElement()
                            .accessibilityLabel("View Finder")
                            .accessibilityAddTraits([.isImage])
                    }
                    .background(.black)
            }
            .task {
                // 视图加载时初始化相机和照片
                await model.camera.start()        // 启动相机
                await model.loadPhotos()          // 加载照片库
                await model.loadThumbnail()       // 加载缩略图
            }
            // 配置导航栏和状态栏
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
        }
    }
    
    /// 创建底部控制按钮视图
    /// 包括：相册按钮、拍照按钮、切换相机按钮
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            Spacer()
            
            // 相册按钮 - 导航到照片集合视图
            NavigationLink {
                PhotoCollectionView(photoCollection: model.photoCollection)
                    .onAppear {
                        // 进入相册时暂停预览
                        model.camera.isPreviewPaused = true
                    }
                    .onDisappear {
                        // 返回时恢复预览
                        model.camera.isPreviewPaused = false
                    }
            } label: {
                Label {
                    Text("Gallery")
                } icon: {
                    ThumbnailView(image: model.thumbnailImage)
                }
            }
            
            // 拍照按钮
            Button {
                model.camera.takePhoto()
            } label: {
                Label {
                    Text("Take Photo")
                } icon: {
                    ZStack {
                        // 外圈白色边框
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 62, height: 62)
                        // 内部白色圆形
                        Circle()
                            .fill(.white)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            
            // 切换前后摄像头按钮
            Button {
                model.camera.switchCaptureDevice()
            } label: {
                Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }
}
