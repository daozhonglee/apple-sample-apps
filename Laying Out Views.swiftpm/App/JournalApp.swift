/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// JournalApp: 应用程序的主入口
@main
struct JournalApp: App {
    @StateObject var journalData = JournalData()  // 管理日记数据的状态对象
    
    var body: some Scene {
        WindowGroup {
            EntryList(journalData: journalData)
                .task {
                    journalData.load()    // 应用启动时加载数据
                }
                .onChange(of: journalData.entries) { _ in
                    journalData.save()     // 数据变化时保存
                }
        }
    }
}
