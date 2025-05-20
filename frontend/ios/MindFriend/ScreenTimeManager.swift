
// ScreenTimeManager.swift (Refactored v2)
import FamilyControls
import ManagedSettings
import DeviceActivity
import SwiftUI

extension DeviceActivityName {
    static let daily = Self("daily")
}

class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()
    private let store = ManagedSettingsStore()
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var selection = FamilyActivitySelection()

    private init() {
        // Do not automatically check authorization at init
    }

    func requestAuthorizationIfNeeded() async throws {
        let status = try await AuthorizationCenter.shared.authorizationStatus
        if status != .approved {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            DispatchQueue.main.async {
                self.authorizationStatus = .approved
            }
        } else {
            DispatchQueue.main.async {
                self.authorizationStatus = status
            }
        }
    }

    func monitorSelectedApps() {
        guard authorizationStatus == .approved else {
            print("Screen Time authorization not granted")
            return
        }

        let appTokens = Set(selection.applications.compactMap { $0.token })
        store.shield.applications = appTokens
        store.shield.applicationCategories = .none

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        do {
            try DeviceActivityCenter().startMonitoring(.daily, during: schedule)
        } catch {
            print("Error starting monitoring: \(error)")
        }
    }

    func stopMonitoring() {
        DeviceActivityCenter().stopMonitoring([.daily])
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
}
