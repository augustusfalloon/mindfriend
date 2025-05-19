import SwiftUI

struct MainTabView: View {
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
    }
}

struct RestrictedAppsView: View {
    @StateObject private var viewModel = RestrictedAppsViewModel()
    @State private var showingJustification = false
    @State private var selectedApp: String?
    @State private var showingAppSelector = false
    @State private var showingRestrictedAppAlert = false
    @State private var restrictedAppToOpen: String?
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Installed Apps")) {
                        ForEach(viewModel.availableApps) { app in
                            HStack {
                                Image(systemName: app.icon)
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                Text(app.name)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { viewModel.isAppRestricted(app) },
                                    set: { isOn in
                                        if isOn {
                                            viewModel.addRestrictedApp(app)
                                            AppLaunchMonitor.shared.restrictApps(viewModel.restrictedApps)
                                        } else {
                                            viewModel.removeRestrictedApp(RestrictedApp(
                                                id: app.bundleId,
                                                name: app.name,
                                                icon: app.icon
                                            ))
                                            AppLaunchMonitor.shared.restrictApps(viewModel.restrictedApps)
                                        }
                                    }
                                ))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if viewModel.isAppRestricted(app) {
                                    restrictedAppToOpen = app.name
                                    showingRestrictedAppAlert = true
                                }
                            }
                        }
                    }
                }
                
                Button(action: {
                    showingAppSelector = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("View All Phone Apps")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Restricted Apps")
            .alert("App Restricted", isPresented: $showingRestrictedAppAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if let appName = restrictedAppToOpen {
                    Text("\(appName) is restricted. Please provide a justification to use it.")
                }
            }
            .sheet(isPresented: $showingAppSelector) {
                AppSelectorView(viewModel: viewModel)
            }
            .onAppear {
                AppLaunchMonitor.shared.startMonitoring()
            }
        }
    }
}

struct AppSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RestrictedAppsViewModel
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Installed Apps")) {
                    ForEach(viewModel.availableApps.filter {
                        searchText.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchText)
                    }) { app in
                        HStack {
                            Image(systemName: app.icon)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text(app.name)
                            Spacer()
                            if viewModel.isAppRestricted(app) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            } else {
                                Button("Add") {
                                    viewModel.addRestrictedApp(app)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Apps")
            .searchable(text: $searchText, prompt: "Search apps")
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            })
        }
    }
}

struct AppRow: View {
    let appName: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(appName)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
}

class RestrictedAppsViewModel: ObservableObject {
    @Published var restrictedApps: [RestrictedApp] = []
    @Published var availableApps: [InstalledApp] = []
    
    init() {
        loadRestrictedApps()
        loadAvailableApps()
    }
    
    private func loadRestrictedApps() {
        // TODO: Implement API call to load restricted apps
        // For now, using mock data
        restrictedApps = [
            RestrictedApp(id: "1", name: "Instagram", icon: "camera.fill"),
            RestrictedApp(id: "2", name: "YouTube", icon: "play.rectangle.fill"),
            RestrictedApp(id: "3", name: "TikTok", icon: "video.fill")
        ]
    }
    
    private func loadAvailableApps() {
        availableApps = AppDetectionService.shared.getInstalledApps()
    }
    
    func isAppRestricted(_ app: InstalledApp) -> Bool {
        restrictedApps.contains { $0.name == app.name }
    }
    
    func addRestrictedApp(_ app: InstalledApp) {
        if !isAppRestricted(app) {
            let newRestrictedApp = RestrictedApp(
                id: app.bundleId,
                name: app.name,
                icon: app.icon
            )
            restrictedApps.append(newRestrictedApp)
            // TODO: Implement API call to save restricted app
        }
    }
    
    func removeRestrictedApp(_ app: RestrictedApp) {
        restrictedApps.removeAll { $0.id == app.id }
        // TODO: Implement API call to remove restricted app
    }
    
    func logAppUsage(appName: String, justification: String) {
        // TODO: Implement API call to log app usage
        print("Logged usage of \(appName) with justification: \(justification)")
    }
}

struct RestrictedApp: Identifiable {
    let id: String
    let name: String
    let icon: String
}

struct AccountSettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account Settings")) {
                    NavigationLink(destination: ProfileSettingsView()) {
                        Label("Profile", systemImage: "person.fill")
                    }
                    NavigationLink(destination: NotificationSettingsView()) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    NavigationLink(destination: PrivacySettingsView()) {
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

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section(header: Text("Push Notifications")) {
                Toggle("Friend Requests", isOn: .constant(true))
                Toggle("App Usage Alerts", isOn: .constant(true))
                Toggle("Friend Activity", isOn: .constant(true))
            }
            
            Section(header: Text("Email Notifications")) {
                Toggle("Weekly Reports", isOn: .constant(true))
                Toggle("Account Updates", isOn: .constant(true))
            }
        }
        .navigationTitle("Notifications")
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        })
    }
}

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section(header: Text("Activity Visibility")) {
                Toggle("Show in Friend Feed", isOn: .constant(true))
                Toggle("Show App Usage", isOn: .constant(true))
            }
            
            Section(header: Text("Data Sharing")) {
                Toggle("Share Usage Statistics", isOn: .constant(false))
                Toggle("Share with Friends", isOn: .constant(true))
            }
        }
        .navigationTitle("Privacy")
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        })
    }
}

#Preview {
    MainTabView()
}
