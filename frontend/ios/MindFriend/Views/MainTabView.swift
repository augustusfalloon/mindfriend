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
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Restricted Apps")) {
                    ForEach(viewModel.restrictedApps) { app in
                        AppRow(app: app, viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("Restricted Apps")
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
    
    init() {
        loadRestrictedApps()
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
    
    func toggleAppRestriction(_ app: RestrictedApp) {
        if let index = restrictedApps.firstIndex(where: { $0.id == app.id }) {
            restrictedApps[index].isRestricted.toggle()
            // TODO: Implement API call to update restriction status
        }
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
