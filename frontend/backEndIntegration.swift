import Foundation

class BackendService {
    static let shared = BackendService()
    private let baseURL = "http://localhost:3000" // Replace with your backend URL

    func saveRestrictions(userId: String, restrictedApps: [String], timeBlocks: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/save-restrictions") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "userId": userId,
            "restrictedApps": restrictedApps,
            "timeBlocks": timeBlocks
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(()))
        }.resume()
    }

    func getRestrictions(userId: String, completion: @escaping (Result<(restrictedApps: [String], timeBlocks: [String]), Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/get-restrictions/\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let restrictedApps = json["restrictedApps"] as? [String],
                   let timeBlocks = json["timeBlocks"] as? [String] {
                    completion(.success((restrictedApps, timeBlocks)))
                } else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}