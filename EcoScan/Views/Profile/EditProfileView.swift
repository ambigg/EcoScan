import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var email: String
    @State private var age: String
    @State private var isLoading = false
    @State private var showingSuccessAlert = false
    
    init() {
        let user = AuthService.shared.currentUser
        _name = State(initialValue: user?.name ?? "")
        _email = State(initialValue: user?.email ?? "")
        if let userAge = user?.age {
            _age = State(initialValue: "\(userAge)")
        } else {
            _age = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.98, green: 0.98, blue: 0.98)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.2, green: 0.6, blue: 0.4),
                                                Color(red: 0.15, green: 0.45, blue: 0.3)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.3), radius: 15, x: 0, y: 5)
                                
                                Text(name.prefix(1).uppercased())
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .font(.caption)
                                                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                                            )
                                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    }
                                }
                                .frame(width: 100, height: 100)
                            }
                            
                            Text("Change Photo")
                                .font(.subheadline)
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                                .fontWeight(.medium)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Name", systemImage: "person.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter your name", text: $name)
                                    .textContentType(.name)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(red: 0.96, green: 0.96, blue: 0.96))
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Email", systemImage: "envelope.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter your email", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(red: 0.96, green: 0.96, blue: 0.96))
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Age", systemImage: "calendar")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter your age (optional)", text: $age)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(red: 0.96, green: 0.96, blue: 0.96))
                                    )
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        )
                        .padding(.horizontal, 24)
                        
                        Button(action: saveChanges) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark")
                                    Text("Save Changes")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.2, green: 0.6, blue: 0.4),
                                                Color(red: 0.15, green: 0.45, blue: 0.3)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .foregroundColor(.white)
                            .shadow(color: Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(name.isEmpty || email.isEmpty || isLoading)
                        .opacity((name.isEmpty || email.isEmpty) ? 0.6 : 1.0)
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your profile has been updated successfully!")
            }
        }
    }
    

    private func saveChanges() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ageValue: Int?
            if let ageInt = Int(age), ageInt > 0 && ageInt < 120 {
                ageValue = ageInt
            } else if age.isEmpty {
                ageValue = nil
            } else {
                ageValue = authService.currentUser?.age
            }
            
            if let ageValue = ageValue {
                authService.updateUserProfile(name: name, email: email, age: ageValue)
            } else {
                authService.updateUserProfile(name: name, email: email)
                authService.updateUserAge(nil)
            }
            
            isLoading = false
            showingSuccessAlert = true
        }
    }}
