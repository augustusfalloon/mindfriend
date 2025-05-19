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
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Restricted Apps")) {
                    ForEach(viewModel.restrictedApps) { app in
                        AppRow(appName: app.name, icon: app.icon)
                            .onTapGesture {
                                selectedApp = app.name
                                showingJustification = true
                            }
                    }
                }
            }
            .navigationTitle("Restricted Apps")
            .sheet(isPresented: $showingJustification) {
                if let appName = selectedApp {
                    JustificationView(
                        appName: appName,
                        onJustificationSubmitted: { justification in
                            viewModel.logAppUsage(appName: appName, justification: justification)
                        },
                        onWaitSelected: {
                            // Handle wait timer completion
                        }
                    )
                }
            }
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
    
    init() {
        // Load restricted apps
        loadRestrictedApps()
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
                    NavigationLink(destination: Text("Profile Settings")) {
                        Label("Profile", systemImage: "person.fill")
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
