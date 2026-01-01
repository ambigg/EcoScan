import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var productService: ProductService
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.1),
                        Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        profileHeader
                        
                        statsSection
                        
                        actionsSection
                        
                        aboutSection
                        
                        logoutButton
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "leaf.circle.fill")
                        .foregroundColor(.ecoGreen)
                        .font(.title2)
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(productService)
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    authService.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .ecoGreen,
                                .ecoGreen.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .ecoGreen.opacity(0.3), radius: 15, x: 0, y: 5)
                
                Text(authService.currentUser?.name.prefix(1).uppercased() ?? "U")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 6) {
                Text(authService.currentUser?.name ?? "User")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(authService.currentUser?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                if let age = authService.currentUser?.age {
                               HStack(spacing: 6) {
                                   Image(systemName: "person.fill")
                                       .font(.caption)
                                       .foregroundColor(.ecoGreen)
                                   Text("\(age) years")
                                       .font(.caption)
                                       .foregroundColor(.secondary)
                               }
                           }
                HStack(spacing: 6) {
                                Image(systemName: "globe")
                                    .font(.caption)
                                    .foregroundColor(.ecoGreen)
                                Text(getAPILocation())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.ecoGreen)
                    Text("Member since \(formattedJoinDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.ecoGreen)
                
                Text("Your Impact")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            HStack(spacing: 16) {
                EnhancedStatCard(
                    value: "\(totalScans)",
                    label: "Products Scanned",
                    icon: "barcode.viewfinder",
                    color: .blue,
                    description: "Last scan: \(lastScanTime)"
                )
                
                EnhancedStatCard(
                    value: "\(goodDecisions)",
                    label: "Eco Choices",
                    icon: "leaf.fill",
                    color: .ecoGreen,
                    description: "\(goodDecisionsPercent)% sustainable"
                )
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.ecoGreen)
                    
                    Text("Impact Summary")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if totalScans > 0 {
                        Text(getImpactLevel())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(getImpactColor())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(getImpactColor().opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                if totalScans > 0 {
                    HStack(spacing: 20) {
                        ImpactMetric(
                            value: String(format: "%.1f", co2Saved),
                            label: "CO₂ Saved",
                            icon: "cloud.fill",
                            color: .blue
                        )
                        
                        Divider()
                            .frame(height: 40)
                        
                        ImpactMetric(
                            value: String(format: "%.1f", plasticSaved),
                            label: "Plastic Avoided",
                            icon: "trash.slash.fill",
                            color: .green
                        )
                    }
                    .padding(.vertical, 8)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundColor(.ecoGreen.opacity(0.6))
                        
                        Text("Start scanning to see your impact!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 24)
        }
    }

    struct ImpactMetric: View {
        let value: String
        let label: String
        let icon: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(color)
                    
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    
                    Text("kg")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(color.opacity(0.7))
                }
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var co2Saved: Double {
        UserDefaults.standard.double(forKey: "totalCO2Saved")
    }

    private var plasticSaved: Double {
        UserDefaults.standard.double(forKey: "totalPlasticSaved")
    }
    private func getAPILocation() -> String {
        let openFoodFactsService = OpenFoodFactsService.shared
        let currentCountry = openFoodFactsService.getCurrentCountry()
        return currentCountry.name
    }
    private func getImpactLevel() -> String {
        let totalImpact = co2Saved + plasticSaved
        
        switch totalImpact {
        case 0:
            return "Beginner"
        case 0..<5:
            return "Starter"
        case 5..<20:
            return "Eco Warrior"
        case 20..<50:
            return "Planet Hero"
        default:
            return "Eco Legend"
        }
    }

    private func getImpactColor() -> Color {
        let totalImpact = co2Saved + plasticSaved
        
        switch totalImpact {
        case 0:
            return .gray
        case 0..<5:
            return .blue
        case 5..<20:
            return .green
        case 20..<50:
            return .orange
        default:
            return .purple
        }
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.ecoGreen)
                
                Text("Account")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                ColorfulActionCard(
                    title: "Edit Profile",
                    icon: "person.crop.circle.fill",
                    color: .blue,
                    action: { showingEditProfile = true }
                )
                
                ColorfulActionCard(
                    title: "Settings",
                    icon: "gearshape.fill",
                    color: .orange,
                    action: { showingSettings = true }
                )
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.ecoGreen)
                
                Text("About & Support")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                ColorfulLinkCard(
                    title: "Terms of Service",
                    icon: "doc.text.fill",
                    color: .purple,
                    url: "https://ecoscan.com/terms"
                )
                
                Divider()
                    .padding(.leading, 56)
                
                ColorfulLinkCard(
                    title: "Privacy Policy",
                    icon: "hand.raised.fill",
                    color: .green,
                    url: "https://ecoscan.com/privacy"
                )
                
                Divider()
                    .padding(.leading, 56)
                
                ColorfulLinkCard(
                    title: "Help & Support",
                    icon: "questionmark.circle.fill",
                    color: .blue,
                    url: "https://ecoscan.com/help"
                )
                
                Divider()
                    .padding(.leading, 56)
                
                HStack(spacing: 16) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.gray)
                        .font(.body)
                        .frame(width: 24)
                    
                    Text("Version")
                        .foregroundColor(.primary)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 24)
        }
    }
    
    private var logoutButton: some View {
        Button {
            showingLogoutAlert = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.body)
                
                Text("Log Out")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    )
            )
            .foregroundColor(.red)
        }
        .padding(.horizontal, 24)
    }
    
    
    private var formattedJoinDate: String {
        guard let date = authService.currentUser?.joinDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    private var totalScans: Int {
        UserDefaults.standard.integer(forKey: "totalProductsScanned")
    }
    
    private var goodDecisions: Int {
        UserDefaults.standard.integer(forKey: "totalGoodDecisions")
    }
    
    private var goodDecisionsPercent: Int {
        guard totalScans > 0 else { return 0 }
        return Int(Double(goodDecisions) / Double(totalScans) * 100)
    }
    
    private var monthlyGoalProgress: Double {
        let goal = 30.0
        let current = Double(goodDecisions)
        return min(current / goal, 1.0)
    }
    
    private var lastScanTime: String {
        guard let lastScan = productService.recentScans.first else {
            return "Never"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastScan.scanDate, relativeTo: Date())
    }
}


struct EnhancedStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    let description: String
    
    @State private var isPulsing = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(isPulsing ? 0.25 : 0.15))
                    .frame(width: 60, height: 60)
                    .scaleEffect(isPulsing ? 1.05 : 1.0)
                
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 2)
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
            
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: color.opacity(0.1), radius: 5, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ColorfulActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ColorfulLinkCard: View {
    let title: String
    let icon: String
    let color: Color
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
        }
    }
}


