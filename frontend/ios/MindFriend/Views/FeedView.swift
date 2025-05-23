import SwiftUI

struct FeedView: View {
    @EnvironmentObject var appContext: AppContext
    @StateObject private var viewModel = FeedViewModel()
    @State private var showingReasonSheet = false
    @State private var selectedApp: AppBackendModel?
    @State private var reason = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.friendActivities) { activity in
                        ActivityRow(activity: activity)
                    }
                }
                .navigationTitle("Friend Activity")
                .refreshable {
                    await viewModel.loadActivities(username: appContext.user?.username ?? "")
                }
                .onAppear {
                    Task {
                        await viewModel.loadActivities(username: appContext.user?.username ?? "")
                        // Load exceeded apps when view appears
                        if let username = appContext.user?.username {
                            viewModel.loadExceededApps(username: username)
                        }
                    }
                }
                
                VStack {
                    Spacer()
                    Button(action: {
                        if let username = appContext.user?.username {
                            viewModel.loadExceededApps(username: username)
                        }
                        showingReasonSheet = true
                    }) {
                        Text("Enter Reason")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showingReasonSheet) {
                NavigationView {
                    Form {
                        Section(header: Text("Select App")) {
                            Picker("App", selection: $selectedApp) {
                                Text("Select an app").tag(nil as AppBackendModel?)
                                ForEach(viewModel.exceededApps, id: \._id) { app in
                                    Text(app.bundleId).tag(app as AppBackendModel?)
                                }
                            }
                        }
                        
                        Section(header: Text("Enter Reason")) {
                            TextEditor(text: $reason)
                                .frame(height: 100)
                        }
                        
                        Section {
                            Button(action: {
                                if let app = selectedApp {
                                    viewModel.addComment(app: app, comment: reason, appContext: appContext)
                                }
                                showingReasonSheet = false
                                selectedApp = nil
                                reason = ""
                            }) {
                                Text("Submit")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                            }
                            .disabled(selectedApp == nil || reason.isEmpty)
                            .listRowBackground(selectedApp == nil || reason.isEmpty ? Color.gray : Color.blue)
                        }
                    }
                    .navigationTitle("Enter Reason")
                    .navigationBarItems(trailing: Button("Cancel") {
                        showingReasonSheet = false
                    })
                }
            }
        }
    }
}

class FeedViewModel: ObservableObject {
    @Published var friendActivities: [FriendActivity] = []
    @Published var exceededApps: [AppBackendModel] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func loadActivities(username: String) async {
        print("Loading activities for username: \(username)")
        getFeed(username: username) { result in
            switch result {
            case .success(let friendAppsList):
                print("\n=== Raw Feed Data ===")
                print("Number of friends with exceeded apps: \(friendAppsList.count)")
                
                for friendApps in friendAppsList {
                    print("\nFriend: \(friendApps.username)")
                    for app in friendApps.apps {
                        print("""
                            - App ID: \(app._id)
                            - Username: \(app.userId)
                            - User ID: \(app.userId)
                            - Bundle ID: \(app.bundleId)
                            - Daily Usage: \(app.dailyUsage)
                            - Restricted: \(app.restricted ?? false)
                            - Comments: \(app.comments ?? "No comments")
                            """)
                    }
                }
                print("=== End Feed Data ===\n")
                
                // Convert FriendApps to FriendActivity array
                var newActivities: [FriendActivity] = []
                
                for friendApps in friendAppsList {
                    for app in friendApps.apps {
                        let activity = FriendActivity(
                            friendId: app.userId,
                            friendName: friendApps.username, // Using userId as name since that's what we have
                            appName: app.bundleId,
                            justification: app.comments ?? "No reason provided"
                        )
                        newActivities.append(activity)
                    }
                }
                
                // Sort activities by timestamp (most recent first)
                self.friendActivities = newActivities.sorted { $0.timestamp > $1.timestamp }
                
            case .failure(let error):
                print("Error loading feed: \(error)")
                // Handle error appropriately
            }
        }
    }
    
    func loadExceededApps(username: String) {
        getExceeded(userId: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let apps):
                    self?.exceededApps = apps
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func addComment(app: AppBackendModel, comment: String, appContext: AppContext) {
        guard let username = appContext.user?.username else { return }
        addCommentToBackend(username: username, bundleID: app.bundleId, comment: comment) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Optionally reload exceeded apps to get updated comments
                    self?.loadExceededApps(username: username)
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}

struct ActivityRow: View {
    let activity: FriendActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.blue)
                Text(activity.friendName)
                    .font(.headline)
                Spacer()
                Text(activity.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("Used \(activity.appName)")
                .font(.subheadline)
            
            if !activity.justification.isEmpty {
                Text(activity.justification)
                    .font(.body)
                    .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 8)
    }
}


#Preview {
    FeedView()
} 
