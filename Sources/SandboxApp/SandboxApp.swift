import SwiftUI

@main
struct SandboxApp: App {
    @State private var store = MemoStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
