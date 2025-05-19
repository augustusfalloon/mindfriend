import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("Full Name", text: $viewModel.fullName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                    
                    TextField("Username", text: $viewModel.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    Task {
                        if await viewModel.signUp() {
                            dismiss()
                        } else {
                            showingAlert = true
                        }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                }
                .disabled(!viewModel.isValid || viewModel.isLoading)
                .padding(.horizontal)
                
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    Button("Log In") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            })
            .alert("Sign Up Failed", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

class SignUpViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    var isValid: Bool {
        !fullName.isEmpty &&
        !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 8 &&
        email.contains("@")
    }
    
    @MainActor
    func signUp() async -> Bool {
        guard isValid else {
            errorMessage = "Please fill in all fields correctly"
            return false
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            // TODO: Implement API call to sign up
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // For now, just print the values
            print("Signing up user: \(username)")
            print("Full Name: \(fullName)")
            print("Email: \(email)")
            
            isLoading = false
            return true
        } catch {
            errorMessage = "Failed to create account. Please try again."
            isLoading = false
            return false
        }
    }
}

#Preview {
    SignUpView()
} 
