import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showingSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("MindFriend")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("Username", text: $viewModel.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !viewModel.loginError.isEmpty {
                        Text(viewModel.loginError)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.login()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isButtonDisabled ? Color.gray : Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(viewModel.isButtonDisabled)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    Button("Sign Up") {
                        showingSignUp = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
                MainTabView()
            }
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
        }
    }
}

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var loginError: String = ""
    
    var isButtonDisabled: Bool {
        isLoading || username.isEmpty || password.isEmpty
    }
    
    @MainActor
    func login() async {
        guard !isButtonDisabled else { return }
        
        isLoading = true
        loginError = ""
        
        do {
            // TODO: Implement API call to login
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // For now, just log in with any credentials
            isLoggedIn = true
        } catch {
            loginError = "Failed to login. Please try again."
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView()
} 
