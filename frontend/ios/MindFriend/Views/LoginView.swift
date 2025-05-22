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
    @EnvironmentObject var appContext: AppContext
    
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
                    errorMessage = "Failed to Login. Invalid Credentials."
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
                    .environmentObject(appContext)
            }
            .sheet(isPresented: $showingSignUp) {
                SignUpView(onSignUpSuccess: { message in
                    successMessage = message
                    showingSuccessAlert = true
                })
                .environmentObject(appContext)
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
        
        // Create a continuation to handle the async completion
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            sendLogin(
                username: username,
                password: password
            ) { result in
                switch result {
                case .success(let response):
                    if let error = response.error {
                        // Handle backend error
                        DispatchQueue.main.async {
                            self.errorMessage = error
                        }
                    } else if let token = response.token {
                        // Success case - store token and proceed
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(token, forKey: "authToken")
                            // Update AppContext with an AppUser object
                            self.appContext.isLoggedIn = true
                            // Here, you should fetch the full user object from your backend. For now, we'll construct a dummy AppUser:
                            let user = AppUser(id: UUID().uuidString, email: "", username: self.username, restrictedApps: [], friends: [])
                            self.appContext.user = user
                            self.isLoggedIn = true
                        }
                    } else {
                        // Handle case where neither error nor token is present
                        DispatchQueue.main.async {
                            self.errorMessage = "Invalid response from server"
                        }
                    }
                case .failure(let error):
                    // Handle network or other errors
                    DispatchQueue.main.async {
                        self.errorMessage = "Login failed: \(error.localizedDescription)"
                    }
                }
                continuation.resume()
            }
        }
    }
}
#Preview {
    LoginView()
} 

