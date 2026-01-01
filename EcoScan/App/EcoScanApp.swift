import SwiftUI


@main
struct EcoScanApp: App {
    @StateObject private var authService = AuthService.shared
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var productService = ProductService()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    MainTabView()
                        .environmentObject(authService)
                        .environmentObject(networkMonitor)
                        .environmentObject(productService)
                } else {
                    LoginView()
                        .environmentObject(authService)
                }
            }
            .preferredColorScheme(.light)
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var productService: ProductService
    @State private var selectedTab = 0
    @State private var showingScanner = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .environmentObject(productService)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                ScanHistoryView()
                    .environmentObject(productService)
                    .tabItem {
                        Label("History", systemImage: "clock.fill")
                    }
                    .tag(1)
                
                ProductInfoView()
                    .tabItem {
                        Label("Info", systemImage: "info.circle.fill")
                    }
                    .tag(2)
                
                ProfileView()
                    .environmentObject(authService)
                    .environmentObject(productService)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            }
            .accentColor(.green)
            
            VStack {
                Spacer()
                Button(action: {
                    showingScanner = true
                }) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.green)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showingScanner) {
            ScannerView()
                .environmentObject(productService)
        }
    }
}
