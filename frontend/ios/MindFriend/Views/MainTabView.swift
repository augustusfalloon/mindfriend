import SwiftUI
import FamilyControls
import UserNotifications

struct MainTabView: View {
    @EnvironmentObject var appContext: AppContext
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
    @State private var showingTimeInput = false
    @State private var timeLimit: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: app.icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(app.name)
            Spacer()
            Button(action: {
                showingTimeInput = true
            }) {
                Text(app.timeLimit > 0 ? "\(app.timeLimit) min" : "Set Time")
                    .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $showingTimeInput) {
            NavigationView {
                Form {
                    Section(header: Text("Set Time Limit")) {
                        TextField("Time in minutes", text: $timeLimit)
                            .keyboardType(.numberPad)
                    }
                }
                .navigationTitle("Time Limit")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showingTimeInput = false
                    },
                    trailing: Button("Save") {
                        if let minutes = Int(timeLimit) {
                            viewModel.updateAppTimeLimit(app, minutes: minutes)
                        }
                        showingTimeInput = false
                    }
                )
            }
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
            RestrictedApp(id: "1", name: "Instagram", icon: "camera.fill", isRestricted: false, timeLimit: 30),
            RestrictedApp(id: "2", name: "YouTube", icon: "play.rectangle.fill", isRestricted: false, timeLimit: 60),
            RestrictedApp(id: "3", name: "TikTok", icon: "video.fill", isRestricted: false, timeLimit: 45)
        ]
    }
    
    private func loadAvailableApps() {
        // Mock data for available apps
        availableApps = [
            RestrictedApp(id: "4", name: "Facebook", icon: "person.2.fill", isRestricted: false, timeLimit: 0),
            RestrictedApp(id: "5", name: "Twitter", icon: "bubble.left.fill", isRestricted: false, timeLimit: 0),
            RestrictedApp(id: "6", name: "Snapchat", icon: "camera.viewfinder", isRestricted: false, timeLimit: 0),
            RestrictedApp(id: "7", name: "Reddit", icon: "globe", isRestricted: false, timeLimit: 0),
            RestrictedApp(id: "8", name: "Pinterest", icon: "pin.fill", isRestricted: false, timeLimit: 0),
            RestrictedApp(id: "9", name: "Contacts", icon: "person.crop.circle.fill", isRestricted: false, timeLimit: 0)
        ]
    }
    
    func updateAppTimeLimit(_ app: RestrictedApp, minutes: Int) {
        if let index = restrictedApps.firstIndex(where: { $0.id == app.id }) {
            restrictedApps[index].timeLimit = minutes
            // TODO: Implement API call to update time limit
        }
    }
    
    func addRestrictedApp(_ app: RestrictedApp) {
        restrictedApps.append(app)
        availableApps.removeAll { $0.id == app.id }
        // TODO: Implement API call to add restricted app
    }
    
    func removeRestrictedApp(_ app: RestrictedApp) {
        restrictedApps.removeAll { $0.id == app.id }
        availableApps.append(app)
        // TODO: Implement API call to remove restricted app
    }
}

struct RestrictedApp: Identifiable {
    let id: String
    let name: String
    let icon: String
    var isRestricted: Bool
    var timeLimit: Int // Time limit in minutes
}

// struct AccountSettingsView: View {
//     @EnvironmentObject var appContext: AppContext
    
//     var body: some View {
//         NavigationView {
//             List {
//                 Section(header: Text("Account Settings")) {
//                     NavigationLink(destination: Text("Profile Settings")) {
//                         Label("Profile", systemImage: "person.fill")
//                     }
//                     NavigationLink(destination: TimePeriodSettingsView()) {
//                         Label("Time Periods", systemImage: "clock.fill")
//                     }
//                     NavigationLink(destination: Text("Notification Settings")) {
//                         Label("Notifications", systemImage: "bell.fill")
//                     }
//                     NavigationLink(destination: Text("Privacy Settings")) {
//                         Label("Privacy", systemImage: "lock.fill")
//                     }
//                 }
                
//                 Section {
//                     Button(action: {
//                         // Logout action
//                         appContext.isLoggedIn = false
//                         appContext.currentUser = nil
//                         UserDefaults.standard.removeObject(forKey: "authToken")
//                     }) {
//                         Text("Logout")
//                             .foregroundColor(.red)
//                     }
//                 }
//             }
//             .navigationTitle("Account Settings")
//         }
//     }
// }

#Preview {
    MainTabView()
} 
