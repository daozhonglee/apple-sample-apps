/*
See the License.txt file for this sample’s licensing information.
*/

import Photos
import os.log

/// 照片集合管理类，负责相册的所有操作
/// 包括：创建相册、加载照片、添加/删除照片等
class PhotoCollection: NSObject, ObservableObject {
    
    // 当前相册中的所有照片资源
    @Published var photoAssets: PhotoAssetCollection = PhotoAssetCollection(PHFetchResult<PHAsset>())
    
    /// 相册的唯一标识符
    var identifier: String? {
        assetCollection?.localIdentifier
    }
    
    // 相册名称
    var albumName: String?
    
    // 智能相册类型（如"最近项目"、"收藏"等）
    var smartAlbumType: PHAssetCollectionSubtype?
    
    // 图片缓存管理器
    let cache = CachedImageManager()
    
    // 对应的 Photos 框架相册集合
    private var assetCollection: PHAssetCollection?
    
    // 如果相册不存在是否创建新相册
    private var createAlbumIfNotFound = false
    
    /// 定义可能出现的错误类型
    enum PhotoCollectionError: LocalizedError {
        case missingAssetCollection      // 相册集合丢失
        case missingAlbumName           // 相册名称缺失
        case missingLocalIdentifier     // 本地标识符缺失
        case unableToFindAlbum(String)  // 无法找到指定相册
        case unableToLoadSmartAlbum(PHAssetCollectionSubtype)  // 无法加载智能相册
        case addImageError(Error)       // 添加图片错误
        case createAlbumError(Error)    // 创建相册错误
        case removeAllError(Error)      // 删除所有照片错误
    }
    
    /// 使用相册名称初始化照片集合
    /// - Parameters:
    ///   - albumName: 相册名称
    ///   - createIfNotFound: 如果相册不存在是否创建新相册
    init(albumNamed albumName: String, createIfNotFound: Bool = false) {
        self.albumName = albumName
        self.createAlbumIfNotFound = createIfNotFound
        super.init()
    }

    /// 使用相册标识符初始化照片集合
    /// - Parameter identifier: 相册的唯一标识符
    /// - Returns: 如果找不到相册则返回nil
    init?(albumWithIdentifier identifier: String) {
        guard let assetCollection = PhotoCollection.getAlbum(identifier: identifier) else {
            logger.error("Photo album not found for identifier: \(identifier)")
            return nil
        }
        logger.log("Loaded photo album with identifier: \(identifier)")
        self.assetCollection = assetCollection
        super.init()
        Task {
            await refreshPhotoAssets()
        }
    }
    
    /// 使用智能相册类型初始化照片集合
    /// 如"最近项目"、"收藏"等系统相册
    init(smartAlbum smartAlbumType: PHAssetCollectionSubtype) {
        self.smartAlbumType = smartAlbumType
        super.init()
    }
    
    /// 在对象释放时取消照片库变化观察
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    /// 加载相册内容
    /// 包括：注册变化观察者、加载智能相册或普通相册
    func load() async throws {
        
        PHPhotoLibrary.shared().register(self)
        
        if let smartAlbumType = smartAlbumType {
            if let assetCollection = PhotoCollection.getSmartAlbum(subtype: smartAlbumType) {
                logger.log("Loaded smart album of type: \(smartAlbumType.rawValue)")
                self.assetCollection = assetCollection
                await refreshPhotoAssets()
                return
            } else {
                logger.error("Unable to load smart album of type: : \(smartAlbumType.rawValue)")
                throw PhotoCollectionError.unableToLoadSmartAlbum(smartAlbumType)
            }
        }
        
        guard let name = albumName, !name.isEmpty else {
            logger.error("Unable to load an album without a name.")
            throw PhotoCollectionError.missingAlbumName
        }
        
        if let assetCollection = PhotoCollection.getAlbum(named: name) {
            logger.log("Loaded photo album named: \(name)")
            self.assetCollection = assetCollection
            await refreshPhotoAssets()
            return
        }
        
        guard createAlbumIfNotFound else {
            logger.error("Unable to find photo album named: \(name)")
            throw PhotoCollectionError.unableToFindAlbum(name)
        }

        logger.log("Creating photo album named: \(name)")
        
        if let assetCollection = try? await PhotoCollection.createAlbum(named: name) {
            self.assetCollection = assetCollection
            await refreshPhotoAssets()
        }
    }
    
    /// 向相册添加新照片
    /// - Parameter imageData: 照片数据
    func addImage(_ imageData: Data) async throws {
        guard let assetCollection = self.assetCollection else {
            throw PhotoCollectionError.missingAssetCollection
        }
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                
                let creationRequest = PHAssetCreationRequest.forAsset()
                if let assetPlaceholder = creationRequest.placeholderForCreatedAsset {
                    creationRequest.addResource(with: .photo, data: imageData, options: nil)
                    
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection), assetCollection.canPerform(.addContent) {
                        let fastEnumeration = NSArray(array: [assetPlaceholder])
                        albumChangeRequest.addAssets(fastEnumeration)
                    }
                }
            }
            
            await refreshPhotoAssets()
            
        } catch let error {
            logger.error("Error adding image to photo library: \(error.localizedDescription)")
            throw PhotoCollectionError.addImageError(error)
        }
    }
    
    /// 从相册中删除指定照片
    /// - Parameter asset: 要删除的照片资源
    func removeAsset(_ asset: PhotoAsset) async throws {
        guard let assetCollection = self.assetCollection else {
            throw PhotoCollectionError.missingAssetCollection
        }
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection) {
                    albumChangeRequest.removeAssets([asset as Any] as NSArray)
                }
            }
            
            await refreshPhotoAssets()
            
        } catch let error {
            logger.error("Error removing all photos from the album: \(error.localizedDescription)")
            throw PhotoCollectionError.removeAllError(error)
        }
    }
    
    /// 删除相册中的所有照片
    func removeAll() async throws {
        guard let assetCollection = self.assetCollection else {
            throw PhotoCollectionError.missingAssetCollection
        }
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection),
                    let assets = (PHAsset.fetchAssets(in: assetCollection, options: nil) as AnyObject?) as! PHFetchResult<AnyObject>? {
                    albumChangeRequest.removeAssets(assets)
                }
            }
            
            await refreshPhotoAssets()
            
        } catch let error {
            logger.error("Error removing all photos from the album: \(error.localizedDescription)")
            throw PhotoCollectionError.removeAllError(error)
        }
    }
    
    /// 刷新相册中的照片资源
    /// 可以指定新的查询结果或重新获取
    /// - Parameter fetchResult: 可选的新查询结果
    private func refreshPhotoAssets(_ fetchResult: PHFetchResult<PHAsset>? = nil) async {

        var newFetchResult = fetchResult

        if newFetchResult == nil {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            if let assetCollection = self.assetCollection, let fetchResult = (PHAsset.fetchAssets(in: assetCollection, options: fetchOptions) as AnyObject?) as? PHFetchResult<PHAsset> {
                newFetchResult = fetchResult
            }
        }
        
        if let newFetchResult = newFetchResult {
            await MainActor.run {
                photoAssets = PhotoAssetCollection(newFetchResult)
                logger.debug("PhotoCollection photoAssets refreshed: \(self.photoAssets.count)")
            }
        }
    }

    /// 根据标识符获取相册
    /// - Parameter identifier: 相册标识符
    /// - Returns: 相册集合对象或nil
    private static func getAlbum(identifier: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [identifier], options: fetchOptions)
        return collections.firstObject
    }
    
    /// 根据名称获取相册
    /// - Parameter name: 相册名称
    /// - Returns: 相册集合对象或nil
    private static func getAlbum(named name: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        return collections.firstObject
    }
    
    /// 获取指定类型的智能相册
    /// - Parameter subtype: 智能相册类型
    /// - Returns: 相册集合对象或nil
    private static func getSmartAlbum(subtype: PHAssetCollectionSubtype) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: fetchOptions)
        return collections.firstObject
    }
    
    /// 创建新的相册
    /// - Parameter name: 相册名称
    /// - Returns: 创建的相册集合对象或nil
    private static func createAlbum(named name: String) async throws -> PHAssetCollection? {
        var collectionPlaceholder: PHObjectPlaceholder?
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                collectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }
        } catch let error {
            logger.error("Error creating album in photo library: \(error.localizedDescription)")
            throw PhotoCollectionError.createAlbumError(error)
        }
        logger.log("Created photo album named: \(name)")
        guard let collectionIdentifier = collectionPlaceholder?.localIdentifier else {
            throw PhotoCollectionError.missingLocalIdentifier
        }
        let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [collectionIdentifier], options: nil)
        return collections.firstObject
    }
}

extension PhotoCollection: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor in
            guard let changes = changeInstance.changeDetails(for: self.photoAssets.fetchResult) else { return }
            await self.refreshPhotoAssets(changes.fetchResultAfterChanges)
        }
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "PhotoCollection")
