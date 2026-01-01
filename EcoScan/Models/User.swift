import Foundation
import Combine

struct User: Identifiable, Codable {
    let id: String
    var email: String
    var name: String
    let joinDate: Date
    var profileImageUrl: String?
    var age: Int?
    var preferences: UserPreferences
    
    struct UserPreferences: Codable {
        var notificationsEnabled: Bool
        var darkMode: Bool
        var openFoodFactsCountry: String?

        
        enum MeasurementUnit: String, Codable {
            case metric, imperial
        }
    }
}

extension User {
    static let demo = User(
        id: "user_123",
        email: "demo@ecoscan.com",
        name: "demo user",
        joinDate: Date(),
        profileImageUrl: nil,
        age:22,
        preferences: UserPreferences(
            notificationsEnabled: true,
            darkMode: false,
            openFoodFactsCountry: "world"
        )
    )
}
