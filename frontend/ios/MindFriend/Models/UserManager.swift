import Foundation

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    
    private let userDefaults = UserDefaults.standard
    private let authTokenKey = "authToken"
    private let userDataKey = "userData"
    
    private init() {
        // Check if user is already logged in
        if let token = userDefaults.string(forKey: authTokenKey) {
            self.isLoggedIn = true
            // Load saved user data if available
            if let userData = userDefaults.data(forKey: userDataKey),
               let user = try? JSONDecoder().decode(User.self, from: userData) {
                self.currentUser = user
            }
        }
    }
    
    func saveUserData(token: String, user: User) {
        userDefaults.set(token, forKey: authTokenKey)
        if let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: userDataKey)
        }
        self.isLoggedIn = true
        self.currentUser = user
    }
    
    func logout() {
        userDefaults.removeObject(forKey: authTokenKey)
        userDefaults.removeObject(forKey: userDataKey)
        self.isLoggedIn = false
        self.currentUser = nil
    }
    
    func getAuthToken() -> String? {
        return userDefaults.string(forKey: authTokenKey)
    }
}

struct User: Codable {
    let id: String
    let username: String
    let email: String
    var restrictedApps: [String]
    var friends: [String]
} 