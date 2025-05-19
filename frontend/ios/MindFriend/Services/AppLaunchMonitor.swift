import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings

class AppLaunchMonitor: ObservableObject {
    static let shared = AppLaunchMonitor()
    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()
    
    func startMonitoring() {
        // Request authorization for Family Controls
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                setupAppMonitoring()
            } catch {
                print("Failed to request authorization: \(error)")
            }
        }
    }
    
    private func setupAppMonitoring() {
        // Create a schedule for monitoring
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        // Start monitoring
        do {
            try center.startMonitoring(
                .daily,
                during: schedule
            )
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }
    
    func restrictApps(_ apps: [RestrictedApp]) {
        let selection = FamilyActivitySelection()
        selection.applications = Set(apps.map { $0.bundleId })
        
        store.shield.applications = selection
        store.shield.applicationCategories = .all()
    }
    
    func removeRestrictions() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
} 