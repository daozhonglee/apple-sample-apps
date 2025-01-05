/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import Foundation

setenv("COREML_CODEGEN_LANGUAGE", "Swift", 1)

@main
struct RPSApp: App {
    @StateObject var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(appModel)
            //#-learning-code-snippet(mlgameview.replace)
            .task {
                await appModel.useLastTrainedModel()
            }
        }
    }
}

