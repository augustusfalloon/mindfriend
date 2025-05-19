import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var searchText = ""
    @State private var showingAddFriend = false
    
    var body: some View {
        NavigationView {
            List {
                // Friend Requests Section
                if !viewModel.pendingRequests.isEmpty {
                    Section(header: Text("Friend Requests")) {
                        ForEach(viewModel.pendingRequests, id: \.self) { request in
                            FriendRequestRow(request: request) { accepted in
                                if accepted {
                                    viewModel.acceptFriendRequest(from: request)
                                } else {
                                    viewModel.declineFriendRequest(from: request)
                                }
                            }
                        }
                    }
                }
                
                // Friends List Section
                Section(header: Text("Friends")) {
                    ForEach(viewModel.friends, id: \.self) { friend in
                        FriendRow(name: friend, status: "Active")
                    }
                }
            }
            .navigationTitle("Friends")
            .searchable(text: $searchText, prompt: "Search friends")
            .onChange(of: searchText) { newValue in
                viewModel.searchFriends(query: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddFriend = true }) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFriend) {
                AddFriendView(viewModel: viewModel)
            }
        }
    }
}

struct FriendRow: View {
    let name: String
    let status: String
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(name)
            Spacer()
            Text(status)
                .foregroundColor(status == "Active" ? .green : .gray)
        }
    }
}

struct FriendRequestRow: View {
    let request: String
    let onResponse: (Bool) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(request)
            Spacer()
            HStack {
                Button(action: { onResponse(true) }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                Button(action: { onResponse(false) }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FriendsViewModel
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Search Results")) {
                    ForEach(viewModel.searchResults, id: \.self) { user in
                        HStack {
                            Text(user)
                            Spacer()
                            Button("Add") {
                                viewModel.sendFriendRequest(to: user)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .navigationTitle("Add Friend")
            .searchable(text: $searchText, prompt: "Search by username")
            .onChange(of: searchText) { newValue in
                viewModel.searchUsers(query: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FriendsView()
} 
