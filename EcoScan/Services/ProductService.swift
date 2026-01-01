import Foundation
import SwiftUI
import Combine

class ProductService: ObservableObject {
    @Published var recentScans: [ScanHistory] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var cachedProducts: [String: Product] = [:]
    private let apiService = OpenFoodFactsService.shared
    
    init() {
        loadHistory()
        loadDemoScans()
    }
    
    func fetchProduct(barcode: String, completion: @escaping (Product?) -> Void) {
        print("Searching for product: \(barcode)")
        
        // 1. Check cache first
        if let cachedProduct = cachedProducts[barcode] {
            print("Product found in cache: \(cachedProduct.name)")
            completion(cachedProduct)
            return
        }
        
        // 2. Check local demo products
        if let demoProduct = Product.demoProducts[barcode] {
            print("Demo product found: \(demoProduct.name)")
            cachedProducts[barcode] = demoProduct
            completion(demoProduct)
            return
        }
        
        // 3. Search in Open Food Facts API
        print("Searching in Open Food Facts API...")
        isLoading = true
        error = nil
        
        Task {
            do {
                let openFoodProduct = try await apiService.fetchProduct(barcode: barcode)
                let product = openFoodProduct.toProduct()
                
                print("API Response - Raw name: \(openFoodProduct.productName ?? "nil"), Brand: \(openFoodProduct.brands ?? "nil")")
                print("Converted product name: \(product.name)")
                
                await MainActor.run {
                    print("Product found in API: \(product.name)")
                    self.cachedProducts[barcode] = product
                    self.isLoading = false
                    completion(product)
                }
            } catch {
                await MainActor.run {
                    print("Error searching for product: \(error.localizedDescription)")
                    self.isLoading = false
                    self.error = error.localizedDescription
                    completion(nil)
                }
            }
        }
    }
    
    func fetchProduct(barcode: String) -> Product? {
        if let cached = cachedProducts[barcode] {
            return cached
        }
        return Product.demoProducts[barcode]
    }
    
    func saveScan(product: Product, decision: ScanHistory.UserDecision) {
        let history = ScanHistory(product: product, decision: decision)
        
        recentScans.insert(history, at: 0)
        saveToUserDefaults()
        updateImpactMetrics(decision: decision, product: product)
        
        print("Scan saved: \(product.name) - \(decision.rawValue)")
    }
    
    private func updateImpactMetrics(decision: ScanHistory.UserDecision, product: Product) {
        var co2Saved = UserDefaults.standard.double(forKey: "totalCO2Saved")
        var plasticSaved = UserDefaults.standard.double(forKey: "totalPlasticSaved")
        var totalScans = UserDefaults.standard.integer(forKey: "totalProductsScanned")
        var goodDecisions = UserDefaults.standard.integer(forKey: "totalGoodDecisions")
        
        totalScans += 1
        
        if decision == .avoided || decision == .alternative {
            if product.ecoScore < 50 {
                co2Saved += 1.0
                plasticSaved += 0.2
            } else {
                co2Saved += 0.5
                plasticSaved += 0.1
            }
            goodDecisions += 1
        } else if decision == .purchased && product.ecoScore >= 70 {
            co2Saved += 0.3
            plasticSaved += 0.05
            goodDecisions += 1
        }
        
        UserDefaults.standard.set(co2Saved, forKey: "totalCO2Saved")
        UserDefaults.standard.set(plasticSaved, forKey: "totalPlasticSaved")
        UserDefaults.standard.set(totalScans, forKey: "totalProductsScanned")
        UserDefaults.standard.set(goodDecisions, forKey: "totalGoodDecisions")
    }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: "scanHistory"),
              let history = try? JSONDecoder().decode([ScanHistory].self, from: data) else {
            print("No saved history found")
            return
        }
        recentScans = history
        print("History loaded: \(history.count) scans")
    }
    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(recentScans) {
            UserDefaults.standard.set(encoded, forKey: "scanHistory")
            print("History saved")
        }
    }
    
    private func loadDemoScans() {
        if recentScans.isEmpty {
            
            if let yogurt = Product.demoProducts["8901234567890"],
               let water = Product.demoProducts["8901234567891"] {
                
                let demoScans = [
                    ScanHistory(
                        id: UUID(),
                        product: yogurt,
                        decision: .purchased
                    ),
                    ScanHistory(
                        id: UUID(),
                        product: water,
                        decision: .avoided
                    )
                ]
                recentScans = demoScans
            }
        }
    }
    
    func getImpactMetrics() -> (co2Saved: Double, plasticSaved: Double, totalScans: Int, goodDecisions: Int) {
        let co2Saved = UserDefaults.standard.double(forKey: "totalCO2Saved")
        let plasticSaved = UserDefaults.standard.double(forKey: "totalPlasticSaved")
        let totalScans = UserDefaults.standard.integer(forKey: "totalProductsScanned")
        let goodDecisions = UserDefaults.standard.integer(forKey: "totalGoodDecisions")
        
        return (co2Saved, plasticSaved, totalScans, goodDecisions)
    }
    
    func clearCache() {
        cachedProducts.removeAll()
        print("Cache cleared")
    }
    
    func resetAllData() {
        recentScans.removeAll()
        cachedProducts.removeAll()
        UserDefaults.standard.removeObject(forKey: "scanHistory")
        UserDefaults.standard.removeObject(forKey: "totalCO2Saved")
        UserDefaults.standard.removeObject(forKey: "totalPlasticSaved")
        UserDefaults.standard.removeObject(forKey: "totalProductsScanned")
        UserDefaults.standard.removeObject(forKey: "totalGoodDecisions")
        loadDemoScans()
        print("All data reset")
    }
    
    func getCacheInfo() -> String {
        return "Cached products: \(cachedProducts.count) | Recent scans: \(recentScans.count)"
    }
}
