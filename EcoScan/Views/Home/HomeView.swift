import SwiftUI

struct HomeView: View {
    @EnvironmentObject var productService: ProductService
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var showingScanner = false
    @State private var showingProfile = false
    @State private var selectedProduct: Product?
    @State private var scanAnimation = false
    
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
                        headerView
                        
                        ImpactMetricsView()
                            .environmentObject(productService)
                            .padding(.horizontal, 20)
                        
                        scanButtonView
                            .padding(.horizontal, 20)
                        
                        recentScansView
                            .padding(.horizontal, 20)
                        
                        if !networkMonitor.isConnected {
                            offlineIndicator
                                .padding(.horizontal, 20)
                        }
                        
                        tipsView
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical)
                }
                .navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $showingScanner) {
            ScannerView()
                .environmentObject(productService)
        }
        .sheet(item: $selectedProduct) { product in
            ProductResultView(product: product)
                .environmentObject(productService)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("EcoScan")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                    
                    Text("Make sustainable choices")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingProfile = true }) {
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
                            .frame(width: 44, height: 44)
                            .shadow(color: Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.3), radius: 8, x: 0, y: 3)
                        
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var scanButtonView: some View {
        Button(action: { showingScanner = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 26))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                        .scaleEffect(scanAnimation ? 1.1 : 1.0)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scan Product")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Check sustainability score")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.15), radius: 15, x: 0, y: 5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever()) {
                scanAnimation.toggle()
            }
        }
    }
    
    private var recentScansView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Scans")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: ScanHistoryView().environmentObject(productService)) {
                    Text("See All")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                }
            }
            
            if productService.recentScans.isEmpty {
                emptyStateView
            } else {
                ForEach(productService.recentScans.prefix(3)) { scan in
                    ScanHistoryRow(scan: scan)
                        .onTapGesture {
                        }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 36))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.5))
            }
            
            VStack(spacing: 8) {
                Text("No scans yet")
                    .font(.headline)
                
                Text("Scan your first product to start tracking your impact")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
    
    private var offlineIndicator: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundColor(.orange)
            
            Text("Offline Mode")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var tipsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                Text("Daily Eco Tip")
                    .font(.headline)
            }
            
            Text("Choose products with glass or paper packaging instead of plastic. Glass is infinitely recyclable!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(16)
                .background(Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.1))
                .cornerRadius(12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
}

