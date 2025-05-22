import Foundation
import Combine

class FriendsViewModel: ObservableObject {
    @Published var friends: [String] = []
    @Published var pendingRequests: [String] = []
    @Published var searchResults: [String] = []
    @Published var error: String?
    @Published var foundUser: String?


    init(){
        loadFriends()
        loadPendingRequests()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    
    func loadFriends() {
        // TODO: Implement API call to load friends
        // For now, using mock data
        friends = ["John Doe", "Jane Smith", "Mike Johnson"]
    }
    
    func loadPendingRequests() {
        // TODO: Implement API call to load pending requests
        // For now, using mock data
        pendingRequests = ["Alice Brown", "Bob Wilson"]
    }
    
    func searchFriends(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        // TODO: Implement API call to search friends
        // For now, using mock data
        searchResults = friends.filter { $0.lowercased().contains(query.lowercased()) }
    }
    
    func searchUsers(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        // TODO: Implement API call to search users
        // For now, using mock data
        searchResults = ["User1", "User2", "User3"].filter { $0.lowercased().contains(query.lowercased()) }
    }
    
    func sendFriendRequest(to userID: String) {
        // TODO: Implement API call to send friend request
        pendingRequests.append(userID)
    }
    
    func acceptFriendRequest(from userID: String) {
        // TODO: Implement API call to accept friend request
        friends.append(userID)
        pendingRequests.removeAll { $0 == userID }
    }
    
    func declineFriendRequest(from userID: String) {
        // TODO: Implement API call to decline friend request
        pendingRequests.removeAll { $0 == userID }
    }
    
    func removeFriend(_ userID: String) {
        // TODO: Implement API call to remove friend
        friends.removeAll { $0 == userID }
    }
    
    func searchForUser(username: String) async -> Bool {
        print("Searching for user: \(username) (placeholder)")
        // TODO: Implement actual backend call to check if user exists
        
        // Simulate a backend check returning true if username is "TestUser", false otherwise
        try? await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        let userExists = username.lowercased() == "testuser"
        
        DispatchQueue.main.async {
            if userExists {
                self.foundUser = username // Set the found user
                self.error = nil // Clear any previous error
                print("User \(username) found (simulated).")
            } else {
                self.foundUser = nil // Clear the found user
                self.error = "User '\(username)' not found." // Set an error
                print("User \(username) not found (simulated).")
            }
        }
        //addFriend(username: username)
        return userExists
    }
    
    // Placeholder for adding a friend -> Implementing actual call with dummy data
    func addFriendButton(userId: String, friendId: String) async {
    //func addFriendButton(userId: String) async {
        print("Attempting to add friend: \(userId)")

    
        // Create a continuation to handle the async completion
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            print("Sending add friend request to backend...")
            
            // Calling the backend addFriend function with dummy data as requested
            // In a real scenario, 'userId' should be the current user's ID, and 'friendID' should be the username to add.
            addFriend(
                userId: "jean",   // Dummy current user ID
                friendId: "Alicej" // Dummy friend ID to add (replace with 'username' parameter later)
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        print("Add friend request sent successfully (dummy data).")
                        // TODO: Handle successful add friend: e.g., show success message, refresh friends list, update UI in AddFriendSheet
                        self.error = nil // Clear any previous error
                        // You might want to dismiss the sheet here or show a confirmation
                        
                    case .failure(let backendError):
                        print("Add friend request failed (dummy data): \(backendError.localizedDescription)")
                        // TODO: Handle add friend failure: e.g., show error message to user
                        self.error = "Failed to add friend: \(backendError.localizedDescription)"
                    }
                }
                continuation.resume()
            }
        }
    }

    // The existing sendFriendRequest function which calls the backend addFriend - let's keep this separate for now.
} 
