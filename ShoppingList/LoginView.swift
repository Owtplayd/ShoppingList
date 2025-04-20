import SwiftUI
import FirebaseCore
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var isAuthenticated = false
    @State private var isLoading = false
    @State private var showPassword = false
    
    // Add validation computed properties
    private var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    private var isValidPassword: Bool {
        return password.count >= 6
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    // App Logo/Title
                    Image(systemName: "cart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    
                    Text("Shopping List")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 30)
                    
                    // Input Fields
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .onChange(of: email) { _ in
                                showError = false
                            }
                        
                        ZStack(alignment: .trailing) {
                            if showPassword {
                                TextField("Password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(isLoginMode ? .password : .newPassword)
                            } else {
                                SecureField("Password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(isLoginMode ? .password : .newPassword)
                            }
                            
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 8)
                        }
                        .onChange(of: password) { _ in
                            showError = false
                        }
                    }
                    .padding(.horizontal)
                    
                    // Validation Messages
                    if !isLoginMode {
                        HStack {
                            Image(systemName: isValidPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(isValidPassword ? .green : .gray)
                            Text("Password must be at least 6 characters")
                                .font(.caption)
                                .foregroundColor(isValidPassword ? .green : .gray)
                        }
                        .padding(.top, 5)
                    }
                    
                    // Error Message
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }
                    
                    // Login/Signup Button
                    Button(action: handleAuthentication) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isLoginMode ? "Log In" : "Sign Up")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isLoading || (!isLoginMode && !isValidPassword))
                    
                    // Toggle between Login/Signup
                    Button(action: {
                        isLoginMode.toggle()
                        errorMessage = ""
                        showError = false
                    }) {
                        Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Log In")
                            .foregroundColor(.blue)
                    }
                    .disabled(isLoading)
                    
                    Spacer()
                }
                .padding()
                .navigationBarHidden(true)
                .onAppear {
                    // Check if user is already signed in
                    if Auth.auth().currentUser != nil {
                        isAuthenticated = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isAuthenticated) {
            ContentView()
        }
    }
    
    private func handleAuthentication() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            showError = true
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            showError = true
            return
        }
        
        guard isValidEmail else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        if !isLoginMode && !isValidPassword {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return
        }
        
        isLoading = true
        
        if isLoginMode {
            // Login
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                handleAuthResult(result: result, error: error)
            }
        } else {
            // Sign Up
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                handleAuthResult(result: result, error: error)
            }
        }
    }
    
    private func handleAuthResult(result: AuthDataResult?, error: Error?) {
        DispatchQueue.main.async {
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                isAuthenticated = true
                email = ""
                password = ""
                errorMessage = ""
                showError = false
            }
        }
    }
}

#Preview {
    LoginView()
} 