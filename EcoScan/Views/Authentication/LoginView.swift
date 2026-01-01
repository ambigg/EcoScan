import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingForgotPassword = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.6, blue: 0.4),
                        Color(red: 0.15, green: 0.45, blue: 0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 40) {
                        Spacer()
                            .frame(height: 40)
                        
                        VStack(spacing: 20) {
                            Image("noBackground")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width:250, height: 150)
                                    .clipped()
                        
                            VStack(spacing: 12) {
                                Text("EcoScan")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Sign in to continue your eco journey")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        
                        VStack(spacing: 24) {
                            CustomTextField(
                                title: "Email",
                                text: $email,
                                icon: "envelope.fill",
                                keyboardType: .emailAddress,
                                autocapitalization: .none
                            )
                            
                            CustomTextField(
                                title: "Password",
                                text: $password,
                                icon: "lock.fill",
                                isSecure: true
                            )
                            
                            Button("Forgot Password?") {
                                showingForgotPassword = true
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        )
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 16) {
                            Button(action: login) {
                                HStack {
                                    if authService.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Login")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                )
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                            }
                            .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
                            .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                            .padding(.horizontal, 24)
                            
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Button("Sign Up") {
                                    showingSignUp = true
                                }
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            }
                            .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
            .alert("Forgot Password", isPresented: $showingForgotPassword) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please contact support at support@ecoscan.com")
            }
            .alert("Error", isPresented: .constant(authService.error != nil)) {
                Button("OK") {
                    authService.error = nil
                }
            } message: {
                Text(authService.error ?? "Unknown error")
            }
        }
    }
    
    private func login() {
        authService.login(email: email, password: password) { success in
        }
    }
}

