import SwiftUI
import FamilyControls
import UserNotifications

struct MainTabView: View {
    @StateObject private var viewModel = RestrictedAppsViewModel()
    @State private var showingEditRestrictedApps = false
    @State private var showingAuthorizationAlert = false
    @State private var authorizationError: String?
    @State private var hasRequestedPermissions = false
    
    var body: some View {
        TabView {
            
            RestrictedAppsView()
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
        .sheet(isPresented: $showingEditRestrictedApps) {
            EditRestrictedAppsView(viewModel: viewModel)
        }
        .onAppear {
            if !hasRequestedPermissions {
                requestPermissions()
            }
        }
        .alert("Permission Required", isPresented: $showingAuthorizationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authorizationError ?? "Please grant the required permissions to use this app.")
        }
    }
    
    private func requestPermissions() {
        // Request Screen Time permissions
        Task {
            do {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            authorizationError = "Failed to request notification permissions: \(error.localizedDescription)"
                            showingAuthorizationAlert = true
                        }
                        hasRequestedPermissions = true
                    }
                }
                
                try await ScreenTimeManager.shared.requestAuthorization()
                // Request notification permissions
                
            } catch {
                DispatchQueue.main.async {
                    authorizationError = "Failed to request Screen Time permissions: \(error.localizedDescription)"
                    showingAuthorizationAlert = true
                    hasRequestedPermissions = true
                }
            }
        }
    }
}

struct RestrictedAppsView: View {
    @StateObject private var viewModel = RestrictedAppsViewModel()
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Restricted Apps")) {
                        ForEach(viewModel.restrictedApps) { app in
                            AppRow(app: app, viewModel: viewModel)
                        }
                    }
                }
                
                Button(action: {
                    showingEditSheet = true
                }) {
                    Text("Edit Restricted Apps")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Restricted Apps")
            .sheet(isPresented: $showingEditSheet) {
                EditRestrictedAppsView(viewModel: viewModel)
            }
        }
    }
}

struct EditRestrictedAppsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RestrictedAppsViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Currently Restricted")) {
                    ForEach(viewModel.restrictedApps) { app in
                        HStack {
                            Image(systemName: app.icon)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text(app.name)
                            Spacer()
                            Button(action: {
                                viewModel.removeRestrictedApp(app)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Section(header: Text("Available Apps")) {
                    ForEach(viewModel.availableApps) { app in
                        HStack {
                            Image(systemName: app.icon)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text(app.name)
                            Spacer()
                            Button(action: {
                                viewModel.addRestrictedApp(app)
                            }) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Restricted Apps")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

struct AppRow: View {
    let app: RestrictedApp
    let viewModel: RestrictedAppsViewModel
    
    var body: some View {
        HStack {
            Image(systemName: app.icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(app.name)
            Spacer()
            Toggle("", isOn: Binding(
                get: { app.isRestricted },
                set: { newValue in
                    viewModel.toggleAppRestriction(app)
                }
            ))
        }
    }
}

class RestrictedAppsViewModel: ObservableObject {
    @Published var restrictedApps: [RestrictedApp] = []
    @Published var availableApps: [RestrictedApp] = []
    
    init() {
        loadRestrictedApps()
        loadAvailableApps()
    }
    
    private func loadRestrictedApps() {
        // TODO: Implement API call to load restricted apps
        // For now, using mock data
        restrictedApps = [
            RestrictedApp(id: "1", name: "Instagram", icon: "camera.fill", isRestricted: false),
            RestrictedApp(id: "2", name: "YouTube", icon: "play.rectangle.fill", isRestricted: false),
            RestrictedApp(id: "3", name: "TikTok", icon: "video.fill", isRestricted: false)
        ]
    }
    
    private func loadAvailableApps() {
        // Mock data for available apps
        availableApps = [
            RestrictedApp(id: "4", name: "Facebook", icon: "person.2.fill", isRestricted: false),
            RestrictedApp(id: "5", name: "Twitter", icon: "bubble.left.fill", isRestricted: false),
            RestrictedApp(id: "6", name: "Snapchat", icon: "camera.viewfinder", isRestricted: false),
            RestrictedApp(id: "7", name: "Reddit", icon: "globe", isRestricted: false),
            RestrictedApp(id: "8", name: "Pinterest", icon: "pin.fill", isRestricted: false),
            RestrictedApp(id: "9", name: "Contacts", icon: "person.crop.circle.fill", isRestricted: false)
        ]
    }
    
    func toggleAppRestriction(_ app: RestrictedApp) {
        if let index = restrictedApps.firstIndex(where: { $0.id == app.id }) {
            restrictedApps[index].isRestricted.toggle()
            // TODO: Implement API call to update restriction status
        }
    }

    func handleAppAccess(_ app: RestrictedApp) {
        NotificationManager.shared.scheduleNotification(for: app)
    }   
    
    func addRestrictedApp(_ app: RestrictedApp) {
        restrictedApps.append(app)
        availableApps.removeAll { $0.id == app.id }
        // TODO: Implement API call to add restricted app
        ScreenTimeManager.shared.monitorAppUsage()
    }
    
    func removeRestrictedApp(_ app: RestrictedApp) {
        restrictedApps.removeAll { $0.id == app.id }
        availableApps.append(app)
        // TODO: Implement API call to remove restricted app
        ScreenTimeManager.shared.monitorAppUsage()
    }

}

struct RestrictedApp: Identifiable {
    let id: String
    let name: String
    let icon: String
    var isRestricted: Bool
}

struct AccountSettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account Settings")) {
                    NavigationLink(destination: Text("Profile Settings")) {
                        Label("Profile", systemImage: "person.fill")
                    }
                    NavigationLink(destination: TimePeriodSettingsView()) {
                        Label("Time Periods", systemImage: "clock.fill")
                    }
                    NavigationLink(destination: Text("Notification Settings")) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    NavigationLink(destination: Text("Privacy Settings")) {
                        Label("Privacy", systemImage: "lock.fill")
                    }
                }
                
                Section {
                    Button(action: {
                        // Logout action
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                            Text("Logout")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Account")
        }
    }
}

#Preview {
    MainTabView()
} 
