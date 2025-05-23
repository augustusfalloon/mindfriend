import SwiftUI
import Foundation
import Combine

struct AddFriendSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appContext: AppContext
    @ObservedObject var viewModel: MindFriend.FriendsViewModel
    @State private var searchText = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Username Input
                TextField("Enter username", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                
                // Add Friend Button
                Button(action: {
                    Task {
                        if let currentUser = appContext.user {
                            await viewModel.addFriendButton(userId: currentUser.username, friendId: searchText) { success in
                                if success {
                                    dismiss()
                                } else {
                                    errorMessage = viewModel.error ?? "Failed to add friend"
                                    showError = true
                                }
                            }
                        } else {
                            errorMessage = "User is not logged in"
                            showError = true
                        }
                    }
                }) {
                    Text("Add Friend")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(searchText.isEmpty)
                
                Spacer()
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    AddFriendSheet(viewModel: MindFriend.FriendsViewModel())
}
