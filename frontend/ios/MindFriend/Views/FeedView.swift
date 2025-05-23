import SwiftUI

struct FeedView: View {
    @EnvironmentObject var appContext: AppContext
    @StateObject private var viewModel = FeedViewModel()
    @State private var showingReasonSheet = false
    @State private var selectedApp = ""
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
                    }
                }
                
                VStack {
                    Spacer()
                    Button(action: {
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
                                ForEach(viewModel.restrictedApps, id: \.self) { app in
                                    Text(app).tag(app)
                                }
                            }
                        }
                        
                        Section(header: Text("Enter Reason")) {
                            TextEditor(text: $reason)
                                .frame(height: 100)
                        }
                        
                        Section {
                            Button(action: {
                                viewModel.addActivity(appName: selectedApp, justification: reason, appContext: appContext)
                                showingReasonSheet = false
                                selectedApp = ""
                                reason = ""
                            }) {
                                Text("Submit")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                            }
                            .disabled(selectedApp.isEmpty || reason.isEmpty)
                            .listRowBackground(selectedApp.isEmpty || reason.isEmpty ? Color.gray : Color.blue)
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

class FeedViewModel: ObservableObject {
    @Published var friendActivities: [FriendActivity] = []
    @Published var restrictedApps: [String] = ["Instagram", "YouTube", "TikTok", "Twitter", "Facebook"]
    
    init() {
        // Initialization moved to onAppear
    }
    
    @MainActor
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
                            friendName: friendApps.username, // Use the username from FriendApps
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
    
    func addActivity(appName: String, justification: String, appContext: AppContext) {
        let newActivity = FriendActivity(
            friendId: appContext.user?.id ?? "",
            friendName: appContext.user?.username ?? "You",
            appName: appName,
            justification: justification
        )
        friendActivities.insert(newActivity, at: 0)
    }
}

#Preview {
    FeedView()
} 