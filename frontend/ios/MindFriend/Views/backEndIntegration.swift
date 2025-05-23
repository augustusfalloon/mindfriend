import Foundation

// this is a sample screen time model, but we can change this based on the screen time api
public struct ScreenTimeRecord: Codable {
    let userId: String
    let appId: String
    let usage: Int
    let date: String
}

public struct LoginRequest: Codable {
    let username: String
    let password: String
}

public struct LoginResponse: Codable {
    let token: String?      // or whatever your backend returns (e.g., userId, username, etc.)
    let error: String?
}

public struct SignupRequest: Codable {
    let username: String
    let email: String
    let password: String
}

public struct SignupResponse: Codable {
    let token: String?
    let error: String?
}

// this will send the screen time data to the backend
func sendScreenTime(record: ScreenTimeRecord, completion: @escaping (Result<ScreenTimeRecord, Error>) -> Void) {
    guard let url = URL(string: "http://localhost:3000/api/apps/") else {
        completion(.failure(NSError(domain: "Invalid URL", code: 0)))
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    do {
        let jsonData = try JSONEncoder().encode(record)
        request.httpBody = jsonData
    } catch {
        completion(.failure(error))
        return
    }
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: 0)))
            return
        }
        do {
            let responseRecord = try JSONDecoder().decode(ScreenTimeRecord.self, from: data)
            completion(.success(responseRecord))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}

// this sends a GET request to get screen time data from the backend if its in the database
func fetchScreenTime(userId: String, completion: @escaping (Result<[ScreenTimeRecord], Error>) -> Void) {
    guard let url = URL(string: "http://localhost:3000/api/apps/\(userId)") else {
        completion(.failure(NSError(domain: "Invalid URL", code: 0)))
        return
    }
    let request = URLRequest(url: url)
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: 0)))
            return
        }
        do {
            let records = try JSONDecoder().decode([ScreenTimeRecord].self, from: data)
            completion(.success(records))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}

// public func sendLogin(username: String, password: String) async throws -> LoginResponse {
//     guard let url = URL(string: "http://localhost:3000/api/users/login") else {
//         throw NSError(domain: "Invalid URL", code: 0)
//     }
    
//     var request = URLRequest(url: url)
//     request.httpMethod = "POST"
//     request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
//     let loginData = LoginRequest(username: username, password: password)
//     let jsonData = try JSONEncoder().encode(loginData)
//     request.httpBody = jsonData
    
//     let (data, _) = try await URLSession.shared.data(for: request)
//     return try JSONDecoder().decode(LoginResponse.self, from: data)
// }

public func sendLogin(username: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
    guard let url = URL(string: "http://localhost:3000/api/users/login") else {
        completion(.failure(NSError(domain: "Invalid URL", code: 0)))
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let loginData = LoginRequest(username: username, password: password)
    do {
        let jsonData = try JSONEncoder().encode(loginData)
        request.httpBody = jsonData
    } catch {
        completion(.failure(error))
        return
    }
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: 0)))
            return
        }
        do {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            completion(.success(loginResponse))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}

// Restrict an app for a user (matches user.js: restrictApp expects userId, bundleID, dailyUsage)
func restrictApp(userId: String, bundleID: String, dailyUsage: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
  guard let url = URL(string: "http://localhost:3000/api/users/restrictApp") else {
    completion(.failure(NSError(domain: "Invalid URL", code: 0)))
    return
  }
  var request = URLRequest(url: url)
  request.httpMethod = "POST"
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  let body: [String: Any] = [
    "userId": userId,
    "bundleID": bundleID,
    "dailyUsage": dailyUsage
  ]
  do {
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
  } catch {
    completion(.failure(error))
    return
  }
  let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let error = error {
      completion(.failure(error))
      return
    }
    completion(.success(true))
  }
  task.resume()
}

// Update an app restriction for a user (matches user.js: updateRestriction expects userId, bundleID, time)
func updateRestriction(userId: String, bundleID: String, time: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
  guard let url = URL(string: "http://localhost:3000/api/users/update-restriction") else {
    completion(.failure(NSError(domain: "Invalid URL", code: 0)))
    return
  }
  var request = URLRequest(url: url)
  request.httpMethod = "PATCH"
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  let body: [String: Any] = [
    "username": userId,
    "bundleID": bundleID,
    "newTime": time
  ]
  do {
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
  } catch {
    completion(.failure(error))
    return
  }
  let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let error = error {
      completion(.failure(error))
      return
    }
    completion(.success(true))
  }
  task.resume()
}

// Add a friend by userId (matches user.js: addFriend expects userId)
public func addFriend(userId: String, friendId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
  guard let url = URL(string: "http://localhost:3000/api/users/add-friend") else {
    completion(.failure(NSError(domain: "Invalid URL", code: 0)))
    return
  }
  var request = URLRequest(url: url)
  request.httpMethod = "POST"
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  let body: [String: Any] = [
    "username": userId,
    "friendUsername": friendId
  ]
  do {
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
  } catch {
    completion(.failure(error))
    return
  }
  let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let error = error {
      completion(.failure(error))
      return
    }
    completion(.success(true))
    
  }
  task.resume()
}

// Define a struct to match the friend object structure from the backend
public struct FriendModel: Codable {
    let _id: String
    let username: String
    // Add other fields if needed
}

public func getFriends(userId: String, completion: @escaping (Result<[String], Error>) -> Void) {
    print("\n=== getFriends Debug ===")
    print("Calling getFriends for userId: \(userId)")
    
    guard let url = URL(string: "http://localhost:3000/api/users/\(userId)/friends") else {
        print("Invalid URL")
        completion(.failure(NSError(domain: "Invalid URL", code: 0)))
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Network error in getFriends: \(error)")
            completion(.failure(error))
            return
        }
        guard let data = data else {
            print("No data received in getFriends")
            completion(.failure(NSError(domain: "No data", code: 0)))
            return
        }
        
        print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
        
        do {
            // First decode as array of FriendModel objects
            let friendObjects = try JSONDecoder().decode([FriendModel].self, from: data)
            // Then extract just the usernames
            let usernames = friendObjects.map { $0.username }
            print("Successfully decoded \(usernames.count) friends: \(usernames)")
            completion(.success(usernames))
        } catch {
            print("Decoding error in getFriends: \(error)")
            completion(.failure(error))
        }
    }
    task.resume()
}

// Define a struct to match the backend AppSchema structure for decoding
public struct AppBackendModel: Codable, Hashable {
    let _id: String // MongoDB default ID
    let userId: String
    let bundleId: String
    let dailyUsage: Int
    let restricted: Bool? // Optional as it has a default value
    let comments: String? // Optional as it has a default value
    // If your backend returns __v for versioning, you might need:
    // let __v: Int?
}

// Function to get a list of apps a user has exceeded their time limit for
public func getExceeded(userId: String, completion: @escaping (Result<[AppBackendModel], Error>) -> Void) {
    print("\n=== getExceeded Debug ===")
    print("Calling getExceeded for userId: \(userId)")
    
    guard let url = URL(string: "http://localhost:3000/api/users/exceeded") else {
        completion(.failure(NSError(domain: "Invalid URL", code: 0)))
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = ["username": userId]
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        print("Request body: \(String(data: request.httpBody!, encoding: .utf8) ?? "Unable to convert body to string")")
    } catch {
        completion(.failure(error))
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Network error in getExceeded: \(error)")
            completion(.failure(error))
            return
        }
        guard let data = data else {
            print("No data received in getExceeded")
            completion(.failure(NSError(domain: "No data", code: 0)))
            return
        }
        
        print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
        
        do {
            let exceededApps = try JSONDecoder().decode([AppBackendModel].self, from: data)
            print("Successfully decoded \(exceededApps.count) apps")
            completion(.success(exceededApps))
        } catch {
            print("Decoding error in getExceeded: \(error)")
            completion(.failure(error))
        }
    }
    task.resume()
}

// Function to get feed data: friends list and exceeded apps for each friend
public func getFeed(username: String, completion: @escaping (Result<[[AppBackendModel]], Error>) -> Void) {
    print("\n=== getFeed Debug ===")
    print("Starting getFeed for username: \(username)")
    
    // Step 1: Get the list of friends for the user
    getFriends(userId: username) { result in
        switch result {
        case .success(let friendsList):
            print("Successfully got friends list: \(friendsList)")
            guard !friendsList.isEmpty else {
                print("Friends list is empty")
                completion(.success([]))
                return
            }
            
            // Step 2: For each friend, get their exceeded apps
            let dispatchGroup = DispatchGroup()
            var exceededAppsResults: [[AppBackendModel]] = []
            var encounteredError: Error?
            
            exceededAppsResults = Array(repeating: [], count: friendsList.count)
            print("Initialized results array for \(friendsList.count) friends")

            for (index, friendUsername) in friendsList.enumerated() {
                print("\nFetching exceeded apps for friend \(index + 1): \(friendUsername)")
                dispatchGroup.enter()
                getExceeded(userId: friendUsername) { exceededResult in
                    defer { dispatchGroup.leave() }
                    
                    switch exceededResult {
                    case .success(let apps):
                        print("Successfully got \(apps.count) exceeded apps for friend \(friendUsername)")
                        exceededAppsResults[index] = apps
                    case .failure(let error):
                        print("Error getting exceeded apps for friend \(friendUsername): \(error)")
                        if encounteredError == nil {
                            encounteredError = error
                        }
                    }
                }
            }
            
            // Step 3: When all getExceeded calls are complete
            dispatchGroup.notify(queue: .main) {
                if let error = encounteredError {
                    print("Encountered error in getFeed: \(error)")
                    completion(.failure(error))
                } else {
                    let nonEmptyResults = exceededAppsResults.filter { !$0.isEmpty }
                    print("Final results: \(nonEmptyResults.count) friends with exceeded apps")
                    completion(.success(nonEmptyResults))
                }
            }
            
        case .failure(let error):
            print("Error getting friends list: \(error)")
            completion(.failure(error))
        }
    }
}


public func sendSignup(username: String, email: String, password: String, completion: @escaping (Result<SignupResponse, Error>) -> Void) {

  guard let url = URL(string: "http://localhost:3000/api/users") else {
    completion(.failure(NSError(domain: "Invalid URL", code: 0)))
    return
  }
  var request = URLRequest(url: url)
  request.httpMethod = "POST"
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  let signupData = SignupRequest(username: username, email: email, password: password)
  do {
    let jsonData = try JSONEncoder().encode(signupData)
    print("Signup Request Data:")
    if let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
    }
    request.httpBody = jsonData
  } catch {
    completion(.failure(error))
    return
  }
  let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let error = error {
      completion(.failure(error))
      return
    }
    guard let data = data else {
      completion(.failure(NSError(domain: "No data", code: 0)))
      return
    }
    do {
      print("Raw data received:")
      print(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")
      print("Attempting to decode...")
      let signupResponse = try JSONDecoder().decode(SignupResponse.self, from: data)
      print("after")
      completion(.success(signupResponse))
    } catch {
      completion(.failure(error))
    }
  }
  task.resume()
}

// here is a sample record to test with
let record = ScreenTimeRecord(
    userId: "user123",
    appId: "com.example.app",
    usage: 120,
    date: ISO8601DateFormatter().string(from: Date())
)

// sendScreenTime(record: record) { result in
//     switch result {
//     case .success(let responseRecord):
//         print("Screen time sent: \(responseRecord)")
//     case .failure(let error):
//         print("Error sending screen time: \(error)")
//     }
// }

// fetchScreenTime(userId: "user123") { result in
//     switch result {
//     case .success(let records):
//         print("Fetched screen time records: \(records)")
//     case .failure(let error):
//         print("Error fetching screen time: \(error)")
//     }
// }

// Struct to match the App schema from backend
public struct AppData: Codable {
    let userId: String
    let bundleId: String
    let dailyUsage: Int
    let restricted: Bool
    let comments: String
}

// Struct to match the user object returned from backend
public struct UserProfile: Codable {
    let restrictedApps: [AppData]?
    // Add other fields if needed
}

// Function to fetch all apps for a user using GET /api/users/:username
public func fetchAllApps(username: String, completion: @escaping (Result<[AppData], Error>) -> Void) {
    guard let url = URL(string: "http://localhost:3000/api/users/\(username)") else {
        completion(.failure(NSError(domain: "Invalid URL", code: 0)))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: 0)))
            return
        }
        // Removed print statement for raw response
        do {
            let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
            let apps = userProfile.restrictedApps ?? []
            completion(.success(apps))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}

// Function to add/update a comment for an app
public func addComment(username: String, bundleID: String, comment: String, completion: @escaping (Result<Bool, Error>) -> Void) {
    guard let url = URL(string: "http://localhost:3000/api/users/add-comment") else {
        completion(.failure(NSError(domain: "Invalid URL", code: 0)))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = [
        "username": username,
        "bundleID": bundleID,
        "comment": comment
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
    } catch {
        completion(.failure(error))
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        // If we get here, the request was successful
        completion(.success(true))
    }
    task.resume()
}
