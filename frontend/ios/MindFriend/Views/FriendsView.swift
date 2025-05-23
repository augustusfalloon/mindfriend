import SwiftUI
import Combine

struct FriendsView: View {
    @EnvironmentObject var appContext: AppContext
    @StateObject private var viewModel = MindFriend.FriendsViewModel()
    @State private var showingAddFriend = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add Friends")) {
                    Button(action: {
                        showingAddFriend = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Add Friend")
                        }
                    }
                }
                
                Section(header: Text("Friends")) {
                    if _viewModel.wrappedValue.isLoading {
                        ProgressView("Loading friends...")
                    } else if viewModel.friends.isEmpty {
                        Text("No friends yet")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.friends, id: \.self) { friend in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.blue)
                                Text(friend)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Friends")
            .refreshable {
                await viewModel.loadFriends(username: appContext.user?.username ?? "")
            }
            .onAppear {
                Task {
                    await viewModel.loadFriends(username: appContext.user?.username ?? "")
                }
            }
            .sheet(isPresented: $showingAddFriend) {
                AddFriendSheet(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    FriendsView()
}
