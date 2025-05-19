import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.friendActivities) { activity in
                    ActivityRow(activity: activity)
                }
            }
            .navigationTitle("Friend Activity")
            .refreshable {
                await viewModel.loadActivities()
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
    
    init() {
        Task {
            await loadActivities()
        }
    }
    
    @MainActor
    func loadActivities() async {
        // TODO: Implement API call to load friend activities
        // For now, using mock data
        friendActivities = [
            FriendActivity(
                friendId: "user1",
                friendName: "John Doe",
                appName: "Instagram",
                justification: "Posting homework"
            ),
            FriendActivity(
                friendId: "user2",
                friendName: "Jane Smith",
                appName: "YouTube",
                justification: "Watching tutorial"
            )
        ]
    }
}

#Preview {
    FeedView()
} 