import Foundation
import SwiftUI

struct ScanHistory: Identifiable, Codable {
    let id: UUID
    let productId: String
    let productName: String
    let brand: String?
    let category: String?
    let imageUrl: String?
    let ecoScore: Int
    let packagingScore: Int
    let carbonScore: Int
    let ethicsScore: Int
    let scanDate: Date
    let decision: UserDecision
    let packagingType: Product.PackagingType
    let certifications: [Product.Certification]
    let materials: [Product.Material]
    let isLocal: Bool
    
    init(id: UUID = UUID(), product: Product, decision: UserDecision) {
        self.id = id
        self.productId = product.id
        self.productName = product.name
        self.brand = product.brand
        self.category = product.category
        self.imageUrl = product.imageUrl
        self.ecoScore = product.ecoScore
        self.packagingScore = product.packagingScore
        self.carbonScore = product.carbonScore
        self.ethicsScore = product.ethicsScore
        self.scanDate = Date()
        self.decision = decision
        self.packagingType = product.packagingType
        self.certifications = product.certifications
        self.materials = product.materials
        self.isLocal = product.isLocal
    }
    
    init(
        id: UUID,
        productId: String,
        productName: String,
        brand: String? = nil,
        category: String? = nil,
        imageUrl: String? = nil,
        ecoScore: Int,
        packagingScore: Int = 50,
        carbonScore: Int = 50,
        ethicsScore: Int = 50,
        scanDate: Date,
        decision: UserDecision,
        packagingType: Product.PackagingType = .mixed,
        certifications: [Product.Certification] = [],
        materials: [Product.Material] = [],
        isLocal: Bool = false
    ) {
        self.id = id
        self.productId = productId
        self.productName = productName
        self.brand = brand
        self.category = category
        self.imageUrl = imageUrl
        self.ecoScore = ecoScore
        self.packagingScore = packagingScore
        self.carbonScore = carbonScore
        self.ethicsScore = ethicsScore
        self.scanDate = scanDate
        self.decision = decision
        self.packagingType = packagingType
        self.certifications = certifications
        self.materials = materials
        self.isLocal = isLocal
    }
    
    enum UserDecision: String, Codable, CaseIterable {
        case purchased = "Purchased"
        case avoided = "Avoided"
        case alternative = "Found Alternative"
        case undecided = "Undecided"
        
        var color: Color {
            switch self {
            case .purchased: return .blue
            case .avoided: return .green
            case .alternative: return .mint
            case .undecided: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .purchased: return "cart.fill"
            case .avoided: return "xmark.circle.fill"
            case .alternative: return "arrow.triangle.2.circlepath"
            case .undecided: return "questionmark.circle.fill"
            }
        }
    }
    
    typealias PurchaseDecision = UserDecision
}

extension ScanHistory {
    static let sample = ScanHistory(
        product: Product.demoProducts["8901234567890"]!,
        decision: .purchased
    )
}
