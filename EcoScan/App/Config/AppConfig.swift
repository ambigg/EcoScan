import SwiftUI

struct AppConfig {
    struct Colors {
        static let primary = Color.green
        static let secondary = Color.blue
        static let accent = Color.orange
        static let background = Color(.systemBackground)
        static let cardBackground = Color(.secondarySystemBackground)
    }
    
    struct Text {
        static let appName = "EcoScan"
        static let appTagline = "Scan for Sustainability"
        static let scannerInstruction = "Point camera at barcode"
    }
    
    struct Icons {
        static let scan = "barcode.viewfinder"
        static let history = "clock.arrow.circlepath"
        static let profile = "person.circle"
        static let settings = "gearshape"
    }
}
