import SwiftUI

@main
struct ElectronicWoodenFishApp: App {
    @StateObject private var manager = WoodenFishManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
        }
    }
}
