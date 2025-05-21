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
        let isValid = !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        email.contains("@")
        
        print("Form validation check - Valid: \(isValid)")
        print("Username empty: \(username.isEmpty)")
        print("Email empty: \(email.isEmpty)")
        print("Password empty: \(password.isEmpty)")
        print("Passwords match: \(password == confirmPassword)")
        print("Password length: \(password.count)")
        print("Email contains @: \(email.contains("@"))")
        
        return isValid
    }
    
    public func signUp() async {
        print("Starting signup process...")
        guard isFormValid else {
            print("Form validation failed")
            errorMessage = "Please fill in all fields correctly"
            return
        }
        
        print("Form validation passed, proceeding with signup")
        print("Attempting signup with username: \(username), email: \(email)")
        
        isLoading = true
        defer { 
            isLoading = false
            print("Signup process completed")
        }
        
        // Create a continuation to handle the async completion
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            print("Sending signup request to backend...")
            sendSignup(
                username: username,
                email: email,
                password: password
            ) { result in
                switch result {
                case .success(let response):
                    if let error = response.error {
                        print("Backend returned error: \(error)")
                        // Handle backend error
                        DispatchQueue.main.async {
                            self.errorMessage = error
                        }
                    } else {
                        print("Signup successful!")
                        // Success case
                        DispatchQueue.main.async {
                            self.onSignUpSuccess("Account created successfully! Please log in.")
                            self.dismiss()
                        }
                    }
                case .failure(let error):
                    print("Signup failed with error: \(error.localizedDescription)")
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
