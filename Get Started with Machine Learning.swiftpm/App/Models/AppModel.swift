/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import Vision // 用于处理计算机视觉任务
import CoreML // 用于机器学习功能

final class AppModel: ObservableObject {
    // 默认机器学习模型的名称
    static let defaultMLModelName = "rockpaperscissors.mlmodel"
    // 相机实例
    let camera = MLCamera()
    // 创建一个定时器，每0.05秒在主线程触发一次预测
    let predictionTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    // 当前使用的机器学习模型，当设置新值时会更新相机的代理
    @Published var currentMLModel: HandPoseMLModel? {
        didSet {
            guard let model = currentMLModel else { return }
            camera.mlDelegate?.updateMLModel(with: model)
        }
    }
    
    // 默认的机器学习模型
    @Published var defaultMLModel: HandPoseMLModel?
    // 可用的手势识别模型集合
    @Published var availableHandPoseMLModels = Set<HandPoseMLModel>()
    
    // 手部关键点的坐标数组
    @Published var nodePoints: [CGPoint] = []
    // 标记是否检测到手在画面中
    @Published var isHandInFrame: Bool = false

    // 预测概率的指标
    @Published var predictionProbability = PredictionMetrics()
    // 是否可以进行预测
    @Published var canPredict: Bool = false
    // 预测的标签（结果）
    @Published var predictionLabel: String = ""
    // 是否正在收集观察数据
    @Published var isGatheringObservations: Bool = true

    // 取景器显示的图像
    @Published var viewfinderImage: Image?
    // 是否应该暂停相机
    @Published var shouldPauseCamera: Bool = false {
        didSet {
            if shouldPauseCamera {
                camera.stop()
                isGatheringObservations = false
            } else {
                Task {
                    await camera.start()
                }
            }
        }
    }

   // 获取所有手势识别模型的URL数组
   private var handposeMLModelURLs: [URL] {
        let urls = availableHandPoseMLModels.map { $0.url }
        return urls
    }
    
    // 初始化方法
    init() {
        camera.mlDelegate = self
        setDefaultMLModel()
        Task {
            await handleCameraPreviews()
        }
    }
    
    // 异步查找现有的模型文件
    func findExistingModels() async {
        // 查找除了当前已加载模型之外的其他模型
        let models = await HandPoseMLModel.findExistingModels(exclude: handposeMLModelURLs)
        // 将找到的模型添加到可用模型集合中
        for model in models {
            availableHandPoseMLModels.insert(model)
        }
    }

    // 使用最近训练的模型
    func useLastTrainedModel() async {
        // 尝试获取最近训练的模型，如果不存在则打印错误信息并返回
        guard let lastTrained = await HandPoseMLModel.getLastTrainedModel() else {
            print("Couldn't find any recently trained ML models.")
            return
        }
        
        // 在主线程上更新当前使用的模型
        Task { @MainActor in
            self.currentMLModel = lastTrained
            // 打印使用新模型的信息
            print("Using last trained ML model in your RPS game: \(lastTrained.name)")
        }
    }

    // 处理相机预览画面的异步函数
    private func handleCameraPreviews() async {
        // 将相机预览流转换为图像流
        let imageStream = camera.previewStream.map { $0.image }
        // 循环处理每一帧图像
        for await image in imageStream {
            // 在主线程上更新预览图像
            Task { @MainActor in
                self.viewfinderImage = image
            }
        }
    }
    
    // 设置默认的机器学习模型
    private func setDefaultMLModel()   {
        Task {
            // 尝试获取默认模型
            guard let mlModel = await HandPoseMLModel.getDefaultMLModel() else { return }
            // 在主线程上更新相关属性
            Task { @MainActor in
                self.defaultMLModel = mlModel
                self.currentMLModel = mlModel
                self.availableHandPoseMLModels.insert(mlModel)
            }
        }
    }
}

// 实现 MLDelegate 协议
extension AppModel: MLDelegate {
    // 更新机器学习模型
    func updateMLModel(with model: NSObject) {
        // 确保传入的模型可以转换为 HandPoseMLModel 类型
        guard let mlModel = model as? HandPoseMLModel else { return }
        // 更新相机的当前模型
        camera.currentMLModel = mlModel
    }

    // 收集摄像头观察到的手势数据
    func gatherObservations(pixelBuffer: CVImageBuffer) async {
        // 确保当前可以进行预测
        guard canPredict else { return }
        
        // 在主线程上将预测标志设为 false
        Task { @MainActor in
            canPredict = false
        }

        // 确保相机有当前的机器学习模型
        guard let mlModel = camera.currentMLModel else {
            await resetPrediction()
            return
        }
        
        Task {
            // 创建图像请求处理器来处理摄像头图像
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
            do {
                // 执行手势识别请求
                try imageRequestHandler.perform([camera.handPoseRequest])
                // 获取第一个手势识别结果
                guard let observation = camera.handPoseRequest.results?.first else {
                    await resetPrediction()
                    return
                }

                // 在主线程更新手势检测状态
                Task { @MainActor in
                    isHandInFrame = true
                    isGatheringObservations = true
                }

                // 获取手势关键点数据
                let poseMultiArray = try observation.keypointsMultiArray()
                
                // 创建输入数据对象
                let input = HandPoseInput(poses: poseMultiArray)
                // 使用模型进行预测
                guard let output = try mlModel.predict(poses: input) else { return }
                // 更新预测结果
                await updatePredictions(output: output)

                // 收集手势关键点坐标
                let jointPoints = try gatherHandPosePoints(from: observation)
                // 更新节点显示
                await updateNodes(points: jointPoints)
            } catch {
                print("Error performing request: \(error)")
            }
        }
    }

    // 从手势观察结果中收集关键点坐标
    private func gatherHandPosePoints(from observation: VNHumanHandPoseObservation) throws -> [CGPoint] {
        // 获取所有识别到的点
        let allPointsDict = try observation.recognizedPoints(.all)
        // 转换为数组
        var allPoints: [VNRecognizedPoint] = Array(allPointsDict.values)
        // 过滤出置信度大于 0.5 的点
        allPoints = allPoints.filter { $0.confidence > 0.5 }
        // 提取坐标信息
        let points: [CGPoint] = allPoints.map { $0.location }
        return points
    }
    
    // 在主线程上更新节点位置
    @MainActor
    private func updateNodes(points: [CGPoint]) {
        self.nodePoints = points
    }

    // 在主线程上更新预测结果
    @MainActor
    private func updatePredictions(output: HandPoseOutput) {
        predictionLabel = output.label.capitalized
        predictionProbability.getNewPredictions(from: output.labelProbabilities)
    }
    
    // 在主线程上重置预测状态
    @MainActor
    private func resetPrediction() {
        nodePoints = []
        predictionLabel = ""
        predictionProbability = PredictionMetrics()
        isHandInFrame = false
    }
}

// CIImage 的私有扩展，用于转换为 SwiftUI Image
fileprivate extension CIImage {
    // 将 CIImage 转换为 SwiftUI Image
    var image: Image? {
        // 创建 Core Image 上下文
        let ciContext = CIContext()
        // 将 CIImage 转换为 CGImage
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        // 创建并返回 SwiftUI Image
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}
