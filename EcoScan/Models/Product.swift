import Foundation

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let brand: String?
    let category: String
    let imageUrl: String?
    
    var ecoScore: Int
    var packagingScore: Int
    var carbonScore: Int
    var ethicsScore: Int
    
    var packagingType: PackagingType
    var certifications: [Certification]
    var materials: [Material]
    var isLocal: Bool
    
    struct Certification: Codable, Hashable {
        let id: String
        let name: String
        let description: String
    }
    
    struct Material: Codable, Hashable {
        let name: String
        let percentage: Double
        let isRecyclable: Bool
    }
    
    
    enum PackagingType: String, Codable, CaseIterable {
        case recyclable = "Recyclable"
        case compostable = "Compostable"
        case reusable = "Reusable"
        case nonRecyclable = "Non-Recyclable"
        case mixed = "Mixed Materials"
    }
}


extension Product {
    static let demoProducts: [String: Product] = [
        "8901234567890": Product(
            id: "8901234567890",
            name: "Organic Greek Yogurt",
            brand: "Nature's Best",
            category: "Dairy",
            imageUrl: nil,
            ecoScore: 85,
            packagingScore: 90,
            carbonScore: 80,
            ethicsScore: 85,
            packagingType: .recyclable,
            certifications: [
                Certification(id: "1", name: "USDA Organic", description: "Certified organic ingredients"),
                Certification(id: "2", name: "Non-GMO", description: "No genetically modified organisms")
            ],
            materials: [
                Material(name: "Glass", percentage: 100, isRecyclable: true)
            ],
            isLocal: true,
        ),
        "7501059200050": Product(
            id: "7501059200050",
            name: "Plastic Water Bottle",
            brand: "Generic",
            category: "Beverages",
            imageUrl: nil,
            ecoScore: 25,
            packagingScore: 20,
            carbonScore: 30,
            ethicsScore: 40,
            packagingType: .nonRecyclable,
            certifications: [],
            materials: [
                Material(name: "PET Plastic", percentage: 100, isRecyclable: false)
            ],
            isLocal: false,

        ),
        "3017620422003": Product(
            id: "3017620422003",
            name: "Nutella",
            brand: "Ferrero",
            category: "Breakfast Foods",
            imageUrl: "https://images.openfoodfacts.org/images/products/301/762/042/2003/front_en.631.400.jpg",
            ecoScore: 45,
            packagingScore: 60,
            carbonScore: 40,
            ethicsScore: 50,
            packagingType: .recyclable,
            certifications: [],
            materials: [
                Material(name: "Glass", percentage: 85, isRecyclable: true),
                Material(name: "Plastic", percentage: 15, isRecyclable: false)
            ],
            isLocal: false,
        ),
        "1234567890123": Product(
            id: "1234567890123",
            name: "Eco-Friendly Detergent",
            brand: "Green Clean",
            category: "Cleaning",
            imageUrl: nil,
            ecoScore: 92,
            packagingScore: 95,
            carbonScore: 88,
            ethicsScore: 90,
            packagingType: .compostable,
            certifications: [
                Certification(id: "3", name: "Vegan", description: "No animal products"),
                Certification(id: "4", name: "Cruelty Free", description: "Not tested on animals")
            ],
            materials: [
                Material(name: "Plant-based Plastic", percentage: 100, isRecyclable: true)
            ],
            isLocal: true,
        )
    ]
}
