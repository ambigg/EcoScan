import Foundation
import SwiftUI
import Combine

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    static let shared = AuthService()
    
    private let userDefaultsKey = "currentUser"
    
    init() {
        loadUserFromDefaults()
    }
    
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            
            let validCredentials = [
                "user@example.com": "password123",
                "test@test.com": "test123",
                "demo@demo.com": "demo123"
            ]
            
            if let correctPassword = validCredentials[email.lowercased()],
               password == correctPassword {
                
                let user = User(
                    id: UUID().uuidString,
                    email: email,
                    name: self.extractNameFromEmail(email),
                    joinDate: Date(),
                    profileImageUrl: nil,
                    age:nil,
                    preferences: User.UserPreferences(
                        notificationsEnabled: true,
                        darkMode: false,
                    openFoodFactsCountry: "world"
                    )
                )
                
                self.currentUser = user
                self.isAuthenticated = true
                self.saveUserToDefaults(user)
                self.error = nil
                completion(true)
                
            } else {
                self.error = "Invalid email or password"
                completion(false)
            }
        }
    }
    func signUp(name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            
            guard self.isValidEmail(email) else {
                self.error = "Please enter a valid email address"
                completion(false)
                return
            }
            
            guard password.count >= 6 else {
                self.error = "Password must be at least 6 characters"
                completion(false)
                return
            }
            
            let user = User(
                id: UUID().uuidString,
                email: email,
                name: name,
                joinDate: Date(),
                profileImageUrl: nil,
                age:nil,
                preferences: User.UserPreferences(
                    notificationsEnabled: true,
                    darkMode: false,
                    openFoodFactsCountry: "world"

                )
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            self.saveUserToDefaults(user)
            self.error = nil
            completion(true)
        }
    }
    func updateUserAge(_ age: Int?) {
        guard var user = currentUser else { return }
        user.age = age
        currentUser = user
        saveUserToDefaults(user)
    }
    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func updateUserProfile(name: String, email: String, age: Int? = nil) {
        guard var user = currentUser else { return }
        user.name = name
        user.email = email
        if let age = age {
                user.age = age
            }
        currentUser = user
        saveUserToDefaults(user)
    }
    
    func updatePreferences(_ preferences: User.UserPreferences) {
        guard var user = currentUser else { return }
        user.preferences = preferences
        currentUser = user
        saveUserToDefaults(user)
    }
    
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func extractNameFromEmail(_ email: String) -> String {
        let components = email.split(separator: "@").first?.split(separator: ".").first
        return String(components?.capitalized ?? "User")
    }
    
    private func saveUserToDefaults(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadUserFromDefaults() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return
        }
        
        currentUser = user
        isAuthenticated = true
    }
}
