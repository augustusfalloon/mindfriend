import SwiftUI
import FamilyControls
import UserNotifications

struct MainTabView: View {
    @EnvironmentObject var appContext: AppContext
    @StateObject private var viewModel: RestrictedAppsViewModel
    @State private var showingEditRestrictedApps = false
    @State private var showingAuthorizationAlert = false
    @State private var authorizationError: String?
    @State private var hasRequestedPermissions = false
    
    init(appContext: AppContext) {
        _viewModel = StateObject(wrappedValue: RestrictedAppsViewModel(appContext: appContext))
    }
    
    var body: some View {
        TabView {
            RestrictedAppsView(viewModel: viewModel)
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
    @EnvironmentObject var appContext: AppContext
    @StateObject private var viewModel: RestrictedAppsViewModel
    @State private var showingEditSheet = false
    
    init(viewModel: RestrictedAppsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading apps...")
                } else if let error = viewModel.error {
                    VStack {
                        Text("Error loading apps")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                        Button("Retry") {
                            viewModel.loadRestrictedApps()
                        }
                        .padding()
                    }
                } else {
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
            }
            .navigationTitle("Restricted Apps")
            .sheet(isPresented: $showingEditSheet) {
                EditRestrictedAppsView(viewModel: viewModel)
            }
            .onAppear {
                if viewModel.appContext !== appContext {
                    viewModel.appContext = appContext
                }
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
    @Published var isLoading = false
    @Published var error: String?
    var appContext: AppContext
    
    init(appContext: AppContext) {
        self.appContext = appContext
        loadRestrictedApps()
        loadAvailableApps()
    }
    
    func loadRestrictedApps() {
        guard let username = appContext.user?.username else {
            error = "User not logged in"
            print("[loadRestrictedApps] ERROR: User not logged in")
            return
        }
        print("[loadRestrictedApps] Sending username to backend:", username)

        isLoading = true
        fetchAllApps(username: username) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let apps):
                    print("[loadRestrictedApps] Received apps from backend:", apps)
                    self?.restrictedApps = apps.map { app in
                        RestrictedApp(
                            id: app.bundleId,
                            name: app.bundleId,
                            icon: "app.fill",
                            isRestricted: app.restricted,
                            timeLimit: app.dailyUsage
                        )
                    }
                case .failure(let error):
                    print("[loadRestrictedApps] ERROR from backend:", error)
                    self?.error = error.localizedDescription
                    // Fallback to mock data if API call fails
                    self?.restrictedApps = [
                        RestrictedApp(id: "1", name: "Instagram", icon: "camera.fill", isRestricted: false, timeLimit: 30),
                        RestrictedApp(id: "2", name: "YouTube", icon: "play.rectangle.fill", isRestricted: false, timeLimit: 60),
                        RestrictedApp(id: "3", name: "TikTok", icon: "video.fill", isRestricted: false, timeLimit: 45)
                    ]
                }
            }
        }
    }
    
    private func loadAvailableApps() {
        // For now, keeping mock data for available apps
        // You might want to implement a separate API endpoint for this
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
        guard let username = appContext.user?.username else {
            error = "User not logged in"
            return
        }
        
        if let index = restrictedApps.firstIndex(where: { $0.id == app.id }) {
            restrictedApps[index].timeLimit = minutes
            updateRestriction(userId: username, bundleID: app.id, time: minutes) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        print("Successfully updated time limit")
                    case .failure(let error):
                        print("Failed to update time limit: \(error)")
                        // Revert the change if the API call fails
                        self?.restrictedApps[index].timeLimit = app.timeLimit
                    }
                }
            }
        }
    }
    
    func addRestrictedApp(_ app: RestrictedApp) {
        guard let username = appContext.user?.username else {
            error = "User not logged in"
            return
        }
        
        restrictedApps.append(app)
        availableApps.removeAll { $0.id == app.id }
        restrictApp(userId: username, bundleID: app.id, dailyUsage: app.timeLimit) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("Successfully added restricted app")
                case .failure(let error):
                    print("Failed to add restricted app: \(error)")
                    // Revert the change if the API call fails
                    self?.restrictedApps.removeAll { $0.id == app.id }
                    self?.availableApps.append(app)
                }
            }
        }
    }
    
    func removeRestrictedApp(_ app: RestrictedApp) {
        guard let username = appContext.user?.username else {
            error = "User not logged in"
            return
        }
        
        restrictedApps.removeAll { $0.id == app.id }
        availableApps.append(app)
        // TODO: Implement API call to remove restricted app
        // Note: You'll need to add a removeRestriction function to backEndIntegration.swift
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
    MainTabView(appContext: AppContext())
} 
