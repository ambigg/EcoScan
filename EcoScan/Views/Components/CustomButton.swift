import SwiftUI

struct CustomButton: View {
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    let title: String
    let style: ButtonStyle
    let isLoading: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return .green
        case .secondary: return Color(.secondarySystemBackground)
        case .destructive: return .red
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return .green
        case .destructive: return .white
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .frame(height: 50)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                } else {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(foregroundColor)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isLoading)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}
