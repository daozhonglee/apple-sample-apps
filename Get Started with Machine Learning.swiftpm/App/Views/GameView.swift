/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct GameView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        RPSGameView(isMLGame: true)
            .environmentObject(appModel)
    }
}
