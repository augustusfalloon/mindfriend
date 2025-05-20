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
                    
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
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
                    errorMessage = nil
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
    
    private func signUp() async {
        guard isFormValid else {
            errorMessage = "Please fill in all fields correctly"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        guard let url = URL(string: "http://localhost:3000/api/auth/signup") else {
            errorMessage = "Invalid server URL"
            return
        }
        
        let signUpData = [
            "username": username,
            "email": email,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: signUpData) else {
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
            
            if httpResponse.statusCode == 201 {
                onSignUpSuccess("Account created successfully! Please log in.")
                dismiss()
            } else {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = errorJson["message"] as? String {
                    errorMessage = message
                } else {
                    errorMessage = "Sign up failed"
                }
            }
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    SignUpView(onSignUpSuccess: { _ in })
} 

