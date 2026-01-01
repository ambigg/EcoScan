import SwiftUI
import AVFoundation

struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var productService: ProductService
    @StateObject private var scanner = BarcodeScanner()
    
    @State private var showingPermissionAlert = false
    @State private var showingResult = false
    @State private var showingNotFoundAlert = false
    @State private var scannedProduct: Product?
    @State private var isSearching = false
    @State private var currentScannedCode: String?
    @State private var demoProduct: Product?
    
    var body: some View {
        NavigationView {
            ZStack {
                if scanner.hasCameraPermission {
                    ScannerCameraView(scanner: scanner)
                        .ignoresSafeArea()
                    
                    ScannerOverlay()
                } else {
                    permissionView
                }
                
                if isSearching {
                    loadingOverlay
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding()
                                .shadow(color: .black.opacity(0.3), radius: 5)
                        }
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    if scanner.hasCameraPermission && !isSearching {
                        instructionView
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                checkCameraPermission()
            }
            .onDisappear {
                scanner.stopScanning()
            }
            .onChange(of: scanner.scannedCode) { code in
                if let code = code, !isSearching {
                    handleScannedCode(code)
                }
            }
            .sheet(isPresented: $showingResult, onDismiss: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    resetScanner()
                }
            }) {
                if let product = scannedProduct {
                    ProductResultView(product: product)
                        .environmentObject(productService)
                }
            }
            .alert("Camera Access Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) { dismiss() }
                Button("Settings") {
                    openAppSettings()
                }
            } message: {
                Text("EcoScan needs camera access to scan barcodes. Please enable camera access in Settings.")
            }
            .alert("Product Not Found", isPresented: $showingNotFoundAlert) {
                Button("Try Again", role: .cancel) {
                    resetScanner()
                }
                Button("Use Demo Product") {
                    loadDemoProduct()
                }
            } message: {
                Text("""
                The barcode '\(currentScannedCode ?? "")' is not yet registered in our database.
                
                You can try scanning a different product or use a demo product to see how EcoScan works.
                """)
            }
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.3), lineWidth: 4)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isSearching)
                    
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                }
                
                VStack(spacing: 8) {
                    Text("Searching Product")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Powered by Open Food Facts")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    if let code = currentScannedCode {
                        Text("Barcode: \(code)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 5)
                    }
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .scaleEffect(0.8)
                        .padding(.top, 10)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.9))
                    .shadow(color: .green.opacity(0.3), radius: 20)
            )
        }
    }
    
    private var permissionView: some View {
        VStack(spacing: 30) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            VStack(spacing: 15) {
                Text("Camera Access Required")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("EcoScan needs camera access to scan product barcodes.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Button("Grant Camera Access") {
                    requestCameraPermission()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
                Button("Use Demo Product") {
                    loadDemoProduct()
                }
                .foregroundColor(.blue)
                .padding(.top, 10)
            }
            .padding()
        }
    }
    
    private var instructionView: some View {
        VStack(spacing: 12) {
            Text("Point camera at barcode")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.7))
                        .shadow(color: .black.opacity(0.3), radius: 5)
                )
            
            Text("Position barcode within the frame")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            VStack(spacing: 6) {
                Text("Try scanning:")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                
                HStack(spacing: 12) {
                    Text("5449000000996")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text("(Coca-Cola)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.top, 5)
        }
        .padding(.bottom, 50)
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            scanner.hasCameraPermission = true
            scanner.startScanning()
        case .notDetermined:
            requestCameraPermission()
        case .denied, .restricted:
            showingPermissionAlert = true
        @unknown default:
            showingPermissionAlert = true
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    scanner.hasCameraPermission = true
                    scanner.startScanning()
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        currentScannedCode = code
        scanner.stopScanning()
        isSearching = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            productService.fetchProduct(barcode: code) { product in
                DispatchQueue.main.async {
                    isSearching = false
                    
                    if let product = product {
                        scannedProduct = product
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showingResult = true
                        }
                    } else {
                        showingNotFoundAlert = true
                    }
                }
            }
        }
    }
    
    private func loadDemoProduct() {
        let demoProduct = Product(
            id: "5449000000996",
            name: "Coca-Cola Original",
            brand: "Coca-Cola",
            category: "Soft Drinks",
            imageUrl: "https://images.openfoodfacts.org/images/products/544/900/000/0996/front_en.668.400.jpg",
            ecoScore: 45,
            packagingScore: 40,
            carbonScore: 50,
            ethicsScore: 35,
            packagingType: .recyclable,
            certifications: [
                Product.Certification(
                    id: "1",
                    name: "Recyclable Packaging",
                    description: "PET bottle is 100% recyclable"
                )
            ],
            materials: [
                Product.Material(name: "PET Plastic", percentage: 100, isRecyclable: true)
            ],
            isLocal: false
        )
        
        isSearching = false
        showingNotFoundAlert = false
        scannedProduct = demoProduct
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingResult = true
        }
    }
    
    private func resetScanner() {
        currentScannedCode = nil
        scannedProduct = nil
        isSearching = false
        showingNotFoundAlert = false
        
        scanner.resetForNewScan()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !scanner.isScanning {
                scanner.startScanning()
            }
        }
    }
    
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
            .environmentObject(ProductService())
    }
}
