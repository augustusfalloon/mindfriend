import SwiftUI


struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    var onSignUpSuccess: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Information")) {
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                    
                    TextField("Password", text: $password)
                    TextField("Confirm Password", text: $confirmPassword)
                }
                
                Section {
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Button(action: {
                            Task {
                                await signUp()
                            }
                        }) {
                            Text("Create Account")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                        .disabled(!isFormValid)
                        .listRowBackground(isFormValid ? Color.blue : Color.gray)
                    }
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = "Sign Up Failed. Invalid Credentials."
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        email.contains("@")
    }
    
    public func signUp() async {
        guard isFormValid else {
            errorMessage = "Please fill in all fields correctly"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // Create a continuation to handle the async completion
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            sendSignup(
                username: username,
                email: email,
                password: password,
                userID: confirmPassword
            ) { result in
                switch result {
                case .success(let response):
                    if let error = response.error {
                        // Handle backend error
                        DispatchQueue.main.async {
                            self.errorMessage = error
                        }
                    } else {
                        // Success case
                        DispatchQueue.main.async {
                            self.onSignUpSuccess("Account created successfully! Please log in.")
                            self.dismiss()
                        }
                    }
                case .failure(let error):
                    // Handle network or other errors
                    DispatchQueue.main.async {
                        self.errorMessage = "Sign up failed: \(error.localizedDescription)"
                    }
                }
                continuation.resume()
            }
        }
    }
}
#Preview {
    SignUpView(onSignUpSuccess: { _ in })
} 
