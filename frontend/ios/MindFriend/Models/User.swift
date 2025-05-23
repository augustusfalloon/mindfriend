import Foundation

struct AppUser: Codable, Identifiable {
    let id: String           // maps to _id from MongoDB
    let email: String
    let username: String
    let restrictedApps: [String]
    let friends: [String]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case username
        case restrictedApps
        case friends
    }
}
