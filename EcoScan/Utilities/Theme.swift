import SwiftUI

struct EcoColors {
    static let primaryGreen = Color("PrimaryGreen")
    static let darkGreen = Color("DarkGreen")
    static let lightGreen = Color("LightGreen")
    
    static let oceanBlue = Color("OceanBlue")
    static let skyBlue = Color("SkyBlue")
    static let earthBrown = Color("EarthBrown")
    static let sunYellow = Color("SunYellow")
    
    static let charcoal = Color("Charcoal")
    static let slateGray = Color("SlateGray")
    static let lightGray = Color("LightGray")
    static let offWhite = Color("OffWhite")
    
    static let success = Color("SuccessGreen")
    static let warning = Color("WarningOrange")
    static let error = Color("ErrorRed")
    static let info = Color("InfoBlue")
}

struct EcoTypography {
    static let primaryFont = "SF Pro Display"
    static let secondaryFont = "SF Pro Text"
    static let accentFont = "Avenir Next"
    
    enum Size {
        case displayLarge, displayMedium, displaySmall
        case headlineLarge, headlineMedium, headlineSmall
        case titleLarge, titleMedium, titleSmall
        case bodyLarge, bodyMedium, bodySmall
        case labelLarge, labelMedium, labelSmall
        case caption
        
        var value: CGFloat {
            switch self {
            case .displayLarge: return 57
            case .displayMedium: return 45
            case .displaySmall: return 36
            case .headlineLarge: return 32
            case .headlineMedium: return 28
            case .headlineSmall: return 24
            case .titleLarge: return 22
            case .titleMedium: return 16
            case .titleSmall: return 14
            case .bodyLarge: return 16
            case .bodyMedium: return 14
            case .bodySmall: return 12
            case .labelLarge: return 14
            case .labelMedium: return 12
            case .labelSmall: return 11
            case .caption: return 10
            }
        }
        
        var weight: Font.Weight {
            switch self {
            case .displayLarge, .displayMedium, .displaySmall:
                return .bold
            case .headlineLarge, .headlineMedium, .headlineSmall:
                return .semibold
            case .titleLarge, .titleMedium, .titleSmall:
                return .medium
            default:
                return .regular
            }
        }
    }
}

struct EcoButtonStyle: ButtonStyle {
    enum Style {
        case primary
        case secondary
        case outline
        case text
        case destructive
    }
    
    let style: Style
    let size: Size
    let fullWidth: Bool
    
    enum Size {
        case large, medium, small
        
        var padding: EdgeInsets {
            switch self {
            case .large:
                return EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
            case .medium:
                return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
            case .small:
                return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            }
        }
        
        var font: Font {
            switch self {
            case .large: return .system(size: 16, weight: .semibold)
            case .medium: return .system(size: 14, weight: .medium)
            case .small: return .system(size: 12, weight: .medium)
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .large: return 16
            case .medium: return 12
            case .small: return 8
            }
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(size.padding)
            .background(background(for: configuration.isPressed))
            .foregroundColor(foregroundColor(for: configuration.isPressed))
            .overlay(overlay)
            .cornerRadius(size.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
    
    private func background(for isPressed: Bool) -> some View {
        Group {
            switch style {
            case .primary:
                LinearGradient(
                    gradient: Gradient(colors: [
                        EcoColors.primaryGreen,
                        EcoColors.darkGreen
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(isPressed ? 0.9 : 1.0)
                
            case .secondary:
                EcoColors.oceanBlue
                    .opacity(isPressed ? 0.9 : 1.0)
                
            case .outline:
                Color.clear
                
            case .text:
                Color.clear
                
            case .destructive:
                EcoColors.error
                    .opacity(isPressed ? 0.9 : 1.0)
            }
        }
    }
    
    private func foregroundColor(for isPressed: Bool) -> Color {
        switch style {
        case .primary, .secondary, .destructive:
            return .white
        case .outline:
            return isPressed ? EcoColors.primaryGreen.opacity(0.8) : EcoColors.primaryGreen
        case .text:
            return isPressed ? EcoColors.charcoal.opacity(0.8) : EcoColors.charcoal
        }
    }
    
    private var overlay: some View {
        Group {
            if style == .outline {
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(EcoColors.primaryGreen, lineWidth: 2)
            } else {
                EmptyView()
            }
        }
    }
}

struct EcoCardStyle: ViewModifier {
    let padding: CGFloat
    let elevation: Elevation
    
    enum Elevation {
        case none, small, medium, large
        
        var shadow: (radius: CGFloat, y: CGFloat) {
            switch self {
            case .none: return (0, 0)
            case .small: return (2, 1)
            case .medium: return (4, 2)
            case .large: return (8, 4)
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(
                color: .black.opacity(0.1),
                radius: elevation.shadow.radius,
                x: 0,
                y: elevation.shadow.y
            )
    }
}

struct EcoBadge: View {
    let text: String
    let style: Style
    let icon: String?
    
    enum Style {
        case success, warning, error, info, neutral
        
        var backgroundColor: Color {
            switch self {
            case .success: return EcoColors.success.opacity(0.1)
            case .warning: return EcoColors.warning.opacity(0.1)
            case .error: return EcoColors.error.opacity(0.1)
            case .info: return EcoColors.info.opacity(0.1)
            case .neutral: return EcoColors.lightGray
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .success: return EcoColors.success
            case .warning: return EcoColors.warning
            case .error: return EcoColors.error
            case .info: return EcoColors.info
            case .neutral: return EcoColors.charcoal
            }
        }
        
        var iconName: String? {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            case .neutral: return nil
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon ?? style.iconName {
                Image(systemName: icon)
                    .font(.system(size: 10))
            }
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(style.backgroundColor)
        .foregroundColor(style.foregroundColor)
        .cornerRadius(12)
    }
}

struct EcoBackgrounds {
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [
            EcoColors.primaryGreen,
            EcoColors.oceanBlue
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let scannerGradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: EcoColors.primaryGreen.opacity(0.1), location: 0),
            .init(color: EcoColors.oceanBlue.opacity(0.05), location: 0.5),
            .init(color: EcoColors.offWhite, location: 1)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let successGradient = LinearGradient(
        gradient: Gradient(colors: [
            EcoColors.success,
            EcoColors.primaryGreen
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
}

struct EcoShapes {
    static let roundedRectangle = RoundedRectangle(cornerRadius: 16, style: .continuous)
    static let capsule = Capsule(style: .continuous)
    static let smallRounded = RoundedRectangle(cornerRadius: 8, style: .continuous)
}

struct EcoAnimations {
    static let gentleSpring = Animation.spring(
        response: 0.3,
        dampingFraction: 0.7,
        blendDuration: 0.3
    )
    
    static let quickSpring = Animation.spring(
        response: 0.2,
        dampingFraction: 0.6,
        blendDuration: 0.2
    )
    
    static let fadeIn = Animation.easeInOut(duration: 0.3)
    static let slide = Animation.easeInOut(duration: 0.4)
}

extension View {
    func ecoCard(padding: CGFloat = 16, elevation: EcoCardStyle.Elevation = .medium) -> some View {
        modifier(EcoCardStyle(padding: padding, elevation: elevation))
    }
    
    func ecoButton(
        style: EcoButtonStyle.Style = .primary,
        size: EcoButtonStyle.Size = .medium,
        fullWidth: Bool = false
    ) -> some View {
        buttonStyle(EcoButtonStyle(style: style, size: size, fullWidth: fullWidth))
    }
    
    func ecoTypography(_ size: EcoTypography.Size) -> some View {
        font(.system(size: size.value, weight: size.weight))
    }
}

struct EcoThemePreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Color Palette")
                        .ecoTypography(.headlineSmall)
                    
                    HStack {
                        colorSample(EcoColors.primaryGreen, "Primary")
                        colorSample(EcoColors.oceanBlue, "Ocean")
                        colorSample(EcoColors.earthBrown, "Earth")
                        colorSample(EcoColors.sunYellow, "Sun")
                    }
                }
                .ecoCard()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Button Styles")
                        .ecoTypography(.headlineSmall)
                    
                    VStack(spacing: 10) {
                        Button("Primary Button") {}
                            .ecoButton(style: .primary, fullWidth: true)
                        
                        Button("Secondary Button") {}
                            .ecoButton(style: .secondary, fullWidth: true)
                        
                        Button("Outline Button") {}
                            .ecoButton(style: .outline, fullWidth: true)
                        
                        Button("Destructive Button") {}
                            .ecoButton(style: .destructive, fullWidth: true)
                    }
                }
                .ecoCard()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Badge Styles")
                        .ecoTypography(.headlineSmall)
                    
                    HStack(spacing: 10) {
                        EcoBadge(text: "Success", style: .success, icon: nil)
                        EcoBadge(text: "Warning", style: .warning, icon: nil)
                        EcoBadge(text: "Error", style: .error, icon: nil)
                        EcoBadge(text: "Info", style: .info, icon: nil)
                    }
                }
                .ecoCard()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Typography")
                        .ecoTypography(.headlineSmall)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Large")
                            .ecoTypography(.displayLarge)
                        Text("Headline Medium")
                            .ecoTypography(.headlineMedium)
                        Text("Body Regular")
                            .ecoTypography(.bodyMedium)
                        Text("Caption")
                            .ecoTypography(.caption)
                    }
                }
                .ecoCard()
            }
            .padding()
        }
        .background(EcoColors.offWhite)
    }
    
    private func colorSample(_ color: Color, _ name: String) -> some View {
        VStack {
            color
                .frame(width: 50, height: 50)
                .cornerRadius(8)
            
            Text(name)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct EcoThemePreview_Previews: PreviewProvider {
    static var previews: some View {
        EcoThemePreview()
    }
}
