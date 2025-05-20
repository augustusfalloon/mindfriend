import FamilyControls
import ManagedSettings
import UserNotifications
import DeviceActivity

class ScreenTimeManager {
    static let shared = ScreenTimeManager()
    private let store = ManagedSettingsStore()
    
    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }
    
    func monitorAppUsage() {
        let selection = FamilyActivitySelection()
        // Filter out nil tokens and force unwrap the non-nil ones since we know they exist
        let applicationTokens = Set(selection.applications.compactMap { $0.token })
        store.shield.applications = applicationTokens
    }
}
