import SwiftUI
import FamilyControls

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var showingSignUp = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showingSuccessAlert = false
    @State private var successMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Text("MindFriend")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Button(action: {
                            Task {
                                await login()
                            }
                        }) {
                            Text("Login")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .disabled(username.isEmpty || password.isEmpty)
                        .opacity(username.isEmpty || password.isEmpty ? 0.6 : 1.0)
                    }
                    
                    Button("Sign Up") {
                        showingSignUp = true
                    }
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            .padding()
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
            .alert("Success", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    showingSuccessAlert = false
                }
            } message: {
                Text(successMessage)
            }
            .fullScreenCover(isPresented: $isLoggedIn) {
                MainTabView()
            }
            .sheet(isPresented: $showingSignUp) {
                SignUpView(onSignUpSuccess: { message in
                    successMessage = message
                    showingSuccessAlert = true
                })
            }
        }
    }
    
    private func login() async {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter both username and password"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // Create the login request
        guard let url = URL(string: "http://localhost:3000/") else {
            errorMessage = "Invalid server URL"
            return
        }
        
        // Create the request body
        let loginData = [
            "username": username,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: loginData) else {
            errorMessage = "Failed to create request data"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid server response"
                return
            }
            
            if httpResponse.statusCode == 200 {
                // Successfully logged in
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["token"] as? String {
                    // Store the token securely
                    UserDefaults.standard.set(token, forKey: "authToken")
                    isLoggedIn = true
                } else {
                    errorMessage = "Invalid response format"
                }
            } else {
                // Handle error response
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = errorJson["message"] as? String {
                    errorMessage = message
                } else {
                    errorMessage = "Login failed"
                }
            }
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    LoginView()
} 