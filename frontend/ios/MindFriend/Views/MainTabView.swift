
// MainTabView.swift (Refactored v2)
import SwiftUI
import FamilyControls
import UserNotifications

struct MainTabView: View {
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @State private var showingFamilyPicker = false
    @State private var showingAuthorizationAlert = false
    @State private var authorizationError: String?
    @State private var hasRequestedNotificationPermissions = false

    var body: some View {
        TabView {
            VStack {
                Text("Restricted Apps")
                    .font(.title2)
                    .padding()

                Button("Select Apps to Restrict") {
                    Task {
                        do {
                            try await screenTimeManager.requestAuthorizationIfNeeded()
                            showingFamilyPicker = true
                        } catch {
                            DispatchQueue.main.async {
                                authorizationError = "Failed to request Screen Time permission: \(error.localizedDescription)"
                                showingAuthorizationAlert = true
                            }
                        }
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)

                Button("Start Monitoring") {
                    screenTimeManager.monitorSelectedApps()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(8)

                Button("Stop Monitoring") {
                    screenTimeManager.stopMonitoring()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(8)
            }
            .tabItem {
                Label("Apps", systemImage: "app.badge")
            }

            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "list.bullet")
                }

            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }

            AccountSettingsView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
        .familyActivityPicker(isPresented: $showingFamilyPicker, selection: $screenTimeManager.selection)
        .onAppear {
            requestNotificationPermissionsIfNeeded()
        }
        .alert("Permission Required", isPresented: $showingAuthorizationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authorizationError ?? "Please grant the required permissions to use this app.")
        }
    }

    private func requestNotificationPermissionsIfNeeded() {
        guard !hasRequestedNotificationPermissions else { return }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.authorizationError = "Failed to request notification permissions: \(error.localizedDescription)"
                    self.showingAuthorizationAlert = true
                }
                self.hasRequestedNotificationPermissions = true
            }
        }
    }
}
