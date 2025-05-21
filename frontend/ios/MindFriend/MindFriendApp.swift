
import SwiftUI

@main
struct MindFriendApp: App {
    @StateObject private var context = AppContext()
    
    init() {
//        Task {
//            do {
//                //try await ScreenTimeManager.shared.requestAuthorization()
//                //try await NotificationManager.shared.requestAuthorization()
//            } catch {
//                print("Authorization error: \(error)")
//            }
//        }
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
