import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var productService: ProductService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var notificationsEnabled: Bool
    @State private var darkModeEnabled: Bool
    @State private var showingClearAlert = false
    @State private var showingAPILocation = false

    
    init() {
        let preferences = AuthService.shared.currentUser?.preferences ??
            User.UserPreferences(
                notificationsEnabled: true,
                darkMode: false
            )
        
        _notificationsEnabled = State(initialValue: preferences.notificationsEnabled)
        _darkModeEnabled = State(initialValue: preferences.darkMode)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.98, green: 0.98, blue: 0.98)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Text("Settings")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 20)
                        
                      
                        VStack(spacing: 0) {
                            SettingsToggle(
                                icon: "bell.fill",
                                title: "Notifications",
                                subtitle: "Get updates about your impact",
                                isOn: $notificationsEnabled
                            )
                            .onChange(of: notificationsEnabled) { _ in updatePreferences() }
                            
                            Divider().padding(.leading, 60)
                            
                            SettingsToggle(
                                icon: "moon.fill",
                                title: "Dark Mode",
                                subtitle: "Reduce eye strain",
                                isOn: $darkModeEnabled
                            )
                            .onChange(of: darkModeEnabled) { newValue in
                                updatePreferences()
                                applyDarkMode(newValue)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        )
                        .padding(.horizontal, 24)
                        
                        // Data Management Section
                        VStack(spacing: 0) {
                            SettingsButton(
                                icon: "trash.fill",
                                title: "Clear Scan History",
                                subtitle: "Remove all past scans",
                                color: .red,
                                action: { showingClearAlert = true }
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        )
                        .padding(.horizontal, 24)

                        VStack(spacing: 0) {
    SettingsButton(
        icon: "network",
        title: "API Location",
        subtitle: "Change Open Food Facts server",
        color: .blue,
        action: { showingAPILocation = true }
    )
}
.background(
    RoundedRectangle(cornerRadius: 20)
        .fill(.white)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
)
.padding(.horizontal, 24)
                        
                        // About Section
                        VStack(spacing: 0) {
                            AboutLink(title: "Rate on App Store", icon: "star.fill", url: "https://apps.apple.com")
                            Divider().padding(.leading, 60)
                            AboutLink(title: "Visit Website", icon: "globe", url: "https://ecoscan.com")
                            Divider().padding(.leading, 60)
                            
                            HStack(spacing: 16) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                                    .frame(width: 24)
                                
                                Text("Version")
                                
                                Spacer()
                                
                                Text("1.0.0")
                                    .foregroundColor(.secondary)
                            }
                            .padding(20)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                        )
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .onAppear {
                updateDarkModeFromSystem()
            }
        }

        .sheet(isPresented: $showingAPILocation) {
    APILocationView(productService: productService)
        .environmentObject(authService)
}

        .alert("Clear Scan History", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearScanHistory()
            }
        } message: {
            Text("Are you sure you want to clear all your scan history? This action cannot be undone.")
        }
    }
    
    private func updatePreferences() {
        let newPreferences = User.UserPreferences(
            notificationsEnabled: notificationsEnabled,
            darkMode: darkModeEnabled
        )
        authService.updatePreferences(newPreferences)
    }
    
    private func clearScanHistory() {
        productService.resetAllData()
        print("Scan history cleared")
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
        
    private func applyDarkMode(_ enabled: Bool) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = enabled ? .dark : .light
            }
        }
        
        UserDefaults.standard.set(enabled, forKey: "darkModeEnabled")
    }
    
    private func updateDarkModeFromSystem() {
        if !UserDefaults.standard.bool(forKey: "darkModeManuallySet") {
            let systemDarkMode = colorScheme == .dark
            darkModeEnabled = systemDarkMode
        }
    }
}


struct SettingsToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(red: 0.2, green: 0.6, blue: 0.4))
        }
        .padding(20)
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(20)
        }
    }
}

struct AboutLink: View {
    let title: String
    let icon: String
    let url: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(20)
        }
    }
}
