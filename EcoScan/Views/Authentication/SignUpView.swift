import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    
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
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            Image("noBackground")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .clipped()
                            Text("Join EcoScan")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Start making sustainable choices today")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 20) {
                            CustomTextField(
                                title: "Full Name",
                                text: $name,
                                icon: "person.fill"
                            )
                            
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
                            
                            CustomTextField(
                                title: "Confirm Password",
                                text: $confirmPassword,
                                icon: "lock.fill",
                                isSecure: true
                            )
                            
                            if !password.isEmpty {
                                PasswordStrengthView(password: password)
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Button {
                                    agreedToTerms.toggle()
                                } label: {
                                    Image(systemName: agreedToTerms ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundColor(agreedToTerms ? Color(red: 0.2, green: 0.6, blue: 0.4) : .gray)
                                }
                                
                                Text("I agree to the Terms of Service and Privacy Policy")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.top, 8)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        )
                        .padding(.horizontal, 24)
                        
                        Button(action: signUp) {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.2, green: 0.6, blue: 0.4)))
                                } else {
                                    Text("Create Account")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white)
                            )
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                        }
                        .disabled(!isFormValid || authService.isLoading)
                        .opacity(!isFormValid ? 0.6 : 1.0)
                        .padding(.horizontal, 24)
                        
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.white.opacity(0.8))
                            
                            Button("Login") {
                                dismiss()
                            }
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        }
                        .font(.subheadline)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.body.weight(.medium))
                    }
                }
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
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        agreedToTerms
    }
    
    private func signUp() {
        authService.signUp(name: name, email: email, password: password) { success in
            if success {
                dismiss()
            }
        }
    }
}

struct PasswordStrengthView: View {
    let password: String
    
    private var strength: Int {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil { score += 1 }
        return score
    }
    
    private var strengthText: String {
        switch strength {
        case 0...1: return "Weak"
        case 2: return "Fair"
        case 3: return "Good"
        default: return "Strong"
        }
    }
    
    private var strengthColor: Color {
        switch strength {
        case 0...1: return .red
        case 2: return .orange
        case 3: return .yellow
        default: return .green
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<4) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < strength ? strengthColor : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
            
            Text("Password strength: \(strengthText)")
                .font(.caption)
                .foregroundColor(strengthColor)
        }
    }
}

