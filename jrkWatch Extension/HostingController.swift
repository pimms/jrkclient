import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
    override var body: AnyView {
        let store = ExtensionDelegate.shared.streamPictureStore
        return AnyView(ContentView().environmentObject(store))
    }
}
