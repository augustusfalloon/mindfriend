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
    let cPassword: String
}

public struct SignupResponse: Codable {
    let success: Bool?
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

public func sendSignup(username: String, email: String, password: String, cPassword: String, completion: @escaping (Result<SignupResponse, Error>) -> Void) {
  guard let url = URL(string: "http://localhost:3000/api/users/createUser") else {
    completion(.failure(NSError(domain: "Invalid URL", code: 0)))
    return
  }
  var request = URLRequest(url: url)
  request.httpMethod = "POST"
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  let signupData = SignupRequest(username: username, email: email, password: password, cPassword: cPassword)
  do {
    let jsonData = try JSONEncoder().encode(signupData)
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
      let signupResponse = try JSONDecoder().decode(SignupResponse.self, from: data)
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