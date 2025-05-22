import SwiftUI
import Foundation
import Combine

struct AddFriendSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appContext: AppContext
    @ObservedObject var viewModel: FriendsViewModel
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var sentRequests = Set<String>()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by username", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: searchText) { newValue in
                            isSearching = true
                            viewModel.searchUsers(query: newValue)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isSearching = false
                            }
                        }
                }
                .padding()
                .background(Color(.systemBackground))

                // Search User Button
                Button(action: {
                    Task {
                        //await viewModel.searchForUser(username: searchText)
                        if let currentUser = appContext.user {
                            await viewModel.addFriendButton(userId: currentUser.username, friendId: searchText)
                        } else{
                            Text("User is not lgoged in.")
                        }
                        //await viewModel.addFriendButton(userId: appContext.user.username, friendId: searchText)
                    }
                }) {
                    Text("Search User")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Display Search Result and Add Friend Button
                // if let foundUser = viewModel.foundUser {
                //     HStack {
                //         Text("Found User:")
                //             .font(.headline)
                //         Text(foundUser)
                //         Spacer()
                //         Button("Add Friend") {
                //             viewModel.addFriend(username: foundUser)
                //         }
                //         .buttonStyle(.bordered)
                //     }
                //     .padding()
                // } else if viewModel.error != nil && !searchText.isEmpty {
                //      // Show error if user not found after searching
                //      Text(viewModel.error ?? "")
                //          .foregroundColor(.red)
                //          .padding()
                // }

                // Results List
                if isSearching {
                    ProgressView("Searching...")
                        .padding()
                } else if viewModel.searchResults.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                        
                        Text("No Users Found")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Try searching with a different username")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.searchResults, id: \.self) { user in
                            FriendRowView(
                                userName: user,
                                sentRequests: $sentRequests,
                                onAddFriend: {
                                    viewModel.sendFriendRequest(to: user)
                                }
                            )
                        }
                    }

                }
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onReceive(viewModel.$error) { newError in
                if let error = newError {
                    errorMessage = error
                    showError = true
                }
            }
        }
    }
}

struct FriendRowView: View {
    let userName: String
    @Binding var sentRequests: Set<String>
    let onAddFriend: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.blue)
                .font(.title2)

            Text(userName)
                .font(.headline)

            Spacer()

            if sentRequests.contains(userName) {
                Text("Request Sent")
                    .foregroundColor(.gray)
                    .font(.caption)
            } else {
                Button(action: {
                    onAddFriend()
                    sentRequests.insert(userName)
                }) {
                    Text("Add")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
