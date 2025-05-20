import Foundation

struct AppUsage: Identifiable, Codable {
    let id: UUID
    let appName: String
    let timestamp: Date
    let justification: String?
    let userId: String
    
    init(appName: String, justification: String? = nil, userId: String) {
        self.id = UUID()
        self.appName = appName
        self.timestamp = Date()
        self.justification = justification
        self.userId = userId
    }
}

struct FriendActivity: Identifiable, Codable {
    let id: UUID
    let friendId: String
    let friendName: String
    let appName: String
    let justification: String
    let timestamp: Date
    
    init(friendId: String, friendName: String, appName: String, justification: String) {
        self.id = UUID()
        self.friendId = friendId
        self.friendName = friendName
        self.appName = appName
        self.justification = justification
        self.timestamp = Date()
    }
} 
