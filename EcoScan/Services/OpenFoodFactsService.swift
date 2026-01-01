import Foundation

class OpenFoodFactsService {
    static let shared = OpenFoodFactsService()
    
    private var baseURL: String {
        let countryCode = UserDefaults.standard.string(forKey: "openFoodFactsCountry") ?? "world"
        if countryCode == "world" {
            return "https://world.openfoodfacts.org/api/v2/product"
        } else {
            return "https://\(countryCode).openfoodfacts.org/api/v2/product"
        }
    }
    
    private let session: URLSession
    private let countryCodes = [
        "world": "World (International)",
        "mx": "Mexico",
        "us": "United States",
        "es": "Spain",
        "fr": "France",
        "de": "Germany",
        "uk": "United Kingdom",
        "it": "Italy",
        "ca": "Canada",
        "br": "Brazil",
        "jp": "Japan",
        "in": "India",
        "au": "Australia"
    ]
    
    public let carbonFootprintDatabase: [String: Double] = [
        "beef": 27.0,
        "lamb": 24.0,
        "cheese": 13.5,
        "pork": 12.1,
        "poultry": 6.9,
        "fish": 6.1,
        "eggs": 4.8,
        "dairy": 3.2,
        "butter": 9.0,
        "vegetables": 0.5,
        "fruits": 0.5,
        "legumes": 0.9,
        "grains": 1.5,
        "bread": 1.4,
        "processed": 2.5,
        "snacks": 3.2,
        "chocolate": 19.0,
        "coffee": 17.0,
        "sugarcane": 1.2,
        "water": 0.3,
        "soda": 0.8,
        "juice": 1.2,
        "beer": 1.0,
        "wine": 1.8
    ]
    
    private let transportImpact: [String: Double] = [
        "local": 0.1,
        "national": 0.3,
        "continental": 0.8,
        "intercontinental": 1.5
    ]
    
    private let processingImpact: [String: Double] = [
        "fresh": 0.0,
        "frozen": 0.4,
        "canned": 0.3,
        "dried": 0.2,
        "ultra-processed": 0.8
    ]
    
    public let packagingMaterialScores: [String: (score: Int, type: Product.PackagingType)] = [
        "glass": (90, .reusable),
        "aluminum": (85, .recyclable),
        "metal": (85, .recyclable),
        "paper": (80, .recyclable),
        "cardboard": (80, .recyclable),
        "pet": (70, .recyclable),
        "hdpe": (65, .recyclable),
        "pp": (60, .recyclable),
        "ps": (40, .nonRecyclable),
        "pvc": (20, .nonRecyclable),
        "mixed": (50, .mixed),
        "compostable": (85, .compostable),
        "biodegradable": (75, .compostable)
    ]
    
    public let certificationWeights: [String: (score: Int, name: String, description: String)] = [
        "organic": (20, "Organic", "No pesticides, sustainable farming"),
        "fair-trade": (18, "Fair Trade", "Fair wages, ethical sourcing"),
        "rainforest-alliance": (15, "Rainforest Alliance", "Biodiversity protection"),
        "carbon-neutral": (15, "Carbon Neutral", "Net-zero carbon emissions"),
        "b-corp": (12, "B Corp", "Social and environmental performance"),
        "vegan": (10, "Vegan", "No animal products"),
        "non-gmo": (8, "Non-GMO", "No genetically modified organisms"),
        "gluten-free": (5, "Gluten Free", "Suitable for celiacs"),
        "halal": (3, "Halal", "Prepared according to Islamic law"),
        "kosher": (3, "Kosher", "Prepared according to Jewish law")
    ]
    
    public let ethicalCountryScores: [String: Int] = [
        "switzerland": 90,
        "norway": 88,
        "denmark": 87,
        "sweden": 86,
        "finland": 85,
        "germany": 82,
        "netherlands": 80,
        "austria": 78,
        "belgium": 77,
        "canada": 75,
        "australia": 74,
        "new zealand": 73,
        "united kingdom": 72,
        "france": 70,
        "mexico": 60,
        "united states": 65,
        "spain": 68,
        "italy": 67,
        "japan": 75,
        "south korea": 70
    ]
    
    public let controversialIngredients: [String: Int] = [
        "palm oil": -15,
        "high fructose corn syrup": -10,
        "artificial colors": -8,
        "artificial flavors": -6,
        "preservatives": -5,
        "trans fats": -12,
        "monosodium glutamate": -4
    ]
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        self.session = URLSession(configuration: configuration)
    }
    
    func getAvailableCountries() -> [(code: String, name: String)] {
        return countryCodes.map { (code: $0.key, name: $0.value) }
            .sorted { $0.code == "mx" ? true : $1.code == "mx" ? false : $0.name < $1.name }
    }
    
    func getCurrentCountry() -> (code: String, name: String) {
        let currentCode = UserDefaults.standard.string(forKey: "openFoodFactsCountry") ?? "world"
        let name = countryCodes[currentCode] ?? "World (International)"
        return (code: currentCode, name: name)
    }
    
    func setCountry(_ countryCode: String) {
        UserDefaults.standard.set(countryCode, forKey: "openFoodFactsCountry")
    }
    
    func fetchProduct(barcode: String) async throws -> OpenFoodFactsProduct {
        let mexicoURL = "https://mx.openfoodfacts.org/api/v2/product/\(barcode).json"
        
        do {
            let mexicanProduct = try await fetchFromURL(urlString: mexicoURL)
            return mexicanProduct
        } catch APIError.productNotFound {
            return try await fetchFromURL(urlString: "\(baseURL)/\(barcode).json")
        } catch {
            return try await fetchFromURL(urlString: "\(baseURL)/\(barcode).json")
        }
    }
    
    private func fetchFromURL(urlString: String) async throws -> OpenFoodFactsProduct {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 404 {
                throw APIError.productNotFound
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let result = try decoder.decode(OpenFoodFactsResponse.self, from: data)
        
        guard result.status == 1, let product = result.product else {
            throw APIError.productNotFound
        }
        
        return product
    }
}

extension OpenFoodFactsProduct {
    func toProduct() -> Product {
        let productName = getProductName()
        
        let ecoScore = calculateEnhancedEcoScore()
        let packagingInfo = analyzeEnhancedPackaging()
        let carbonScore = calculateEnhancedCarbonScore()
        let ethicsScore = calculateEnhancedEthicsScore()
        
        return Product(
            id: code ?? UUID().uuidString,
            name: productName,
            brand: getBrand(),
            category: getCategory(),
            imageUrl: imageFrontUrl ?? imageUrl,
            ecoScore: ecoScore,
            packagingScore: packagingInfo.score,
            carbonScore: carbonScore,
            ethicsScore: ethicsScore,
            packagingType: packagingInfo.type,
            certifications: parseEnhancedCertifications(),
            materials: parseEnhancedMaterials(),
            isLocal: isLocalProduct()
        )
    }
    
    private func getProductName() -> String {
        if let name = productName, !name.isEmpty {
            return name
        } else if let brand = brands, let category = categories?.components(separatedBy: ",").first {
            return "\(brand) \(category)"
        } else if let brand = brands {
            return brand
        } else if let category = categories?.components(separatedBy: ",").first {
            return category
        } else {
            return "Product"
        }
    }
    
    private func getBrand() -> String? {
        return brands
    }
    
    private func getCategory() -> String {
        guard let categories = categories else { return "General" }
        return categories.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? "General"
    }
    
    private func isLocalProduct() -> Bool {
        guard let countries = countries?.lowercased() else { return false }
        
        let currentCountry = UserDefaults.standard.string(forKey: "openFoodFactsCountry") ?? "mx"
        let targetCountry = currentCountry == "world" ? "mx" : currentCountry
        
        return countries.contains(targetCountry) || 
               countries.contains("mexico") || 
               countries.contains("méxico") ||
               (manufacturingPlaces?.lowercased().contains(targetCountry) ?? false) ||
               (origins?.lowercased().contains(targetCountry) ?? false)
    }
    
    private func calculateEnhancedCarbonScore() -> Int {
        var baseScore = 50
        
        let categoryImpact = calculateCategoryCarbonImpact()
        baseScore += categoryImpact
        
        let transportImpact = calculateTransportImpact()
        baseScore += transportImpact
        
        let processingImpact = calculateProcessingImpact()
        baseScore += processingImpact
        
        let packagingImpact = calculatePackagingCarbonImpact()
        baseScore += packagingImpact
        
        let certificationBonus = calculateCarbonCertificationBonus()
        baseScore += certificationBonus
        
        return max(0, min(100, baseScore))
    }
    
    private func calculateCategoryCarbonImpact() -> Int {
        guard let categories = categories?.lowercased() else { return 0 }
        
        for (categoryKey, carbonValue) in OpenFoodFactsService.shared.carbonFootprintDatabase {
            if categories.contains(categoryKey) {
                let score = Int(100 - (carbonValue * 3.33))
                return score - 50
            }
        }
        
        return -10
    }
    
    private func calculateTransportImpact() -> Int {
        guard let countries = countries?.lowercased() else { return 0 }
        
        let currentCountry = UserDefaults.standard.string(forKey: "openFoodFactsCountry") ?? "mx"
        
        if countries.contains(currentCountry) || isLocalProduct() {
            return 15
        } else if countries.contains("usa") || countries.contains("canada") {
            return 5
        } else if countries.contains("spain") || countries.contains("france") || countries.contains("germany") {
            return 0
        } else if countries.contains("china") || countries.contains("brazil") {
            return -5
        } else {
            return -10
        }
    }
    
    private func calculateProcessingImpact() -> Int {
        guard let categories = categories?.lowercased() else { return 0 }
        
        if categories.contains("fresh") || categories.contains("raw") {
            return 10
        } else if categories.contains("frozen") {
            return 0
        } else if categories.contains("canned") {
            return -5
        } else if categories.contains("processed") || categories.contains("ultra-processed") {
            return -10
        }
        
        return 0
    }
    
    private func calculatePackagingCarbonImpact() -> Int {
        let packagingInfo = analyzeEnhancedPackaging()
        
        switch packagingInfo.type {
        case .reusable:
            return 10
        case .compostable:
            return 8
        case .recyclable:
            return 5
        case .mixed:
            return -5
        case .nonRecyclable:
            return -10
        }
    }
    
    private func calculateCarbonCertificationBonus() -> Int {
        var bonus = 0
        
        if let labels = labelsTags {
            if labels.contains(where: { $0.contains("carbon-neutral") }) {
                bonus += 15
            }
            if labels.contains(where: { $0.contains("climate-neutral") }) {
                bonus += 10
            }
            if labels.contains(where: { $0.contains("renewable-energy") }) {
                bonus += 8
            }
        }
        
        return min(bonus, 15)
    }
    
    private func calculateEnhancedEthicsScore() -> Int {
        var score = 50
        
        let certificationScore = calculateEnhancedCertificationScore()
        score += certificationScore
        
        let countryScore = calculateCountryEthicsScore()
        score += countryScore
        
        let ingredientScore = calculateIngredientEthicsScore()
        score += ingredientScore
        
        let brandScore = calculateBrandEthicsScore()
        score += brandScore
        
        return max(0, min(100, score))
    }
    
    private func calculateEnhancedCertificationScore() -> Int {
        var totalScore = 0
        
        if let labels = labelsTags {
            for label in labels {
                for (certKey, certData) in OpenFoodFactsService.shared.certificationWeights {
                    if label.contains(certKey) {
                        totalScore += certData.score
                        break
                    }
                }
            }
        }
        
        return min(20, totalScore) - 10
    }
    
    private func calculateCountryEthicsScore() -> Int {
        guard let countries = countries?.lowercased() else { return 0 }
        
        for (country, score) in OpenFoodFactsService.shared.ethicalCountryScores {
            if countries.contains(country) {
                return (score - 65) / 2
            }
        }
        
        return 0
    }
    
    private func calculateIngredientEthicsScore() -> Int {
        var penalty = 0
        
        if let ingredientsText = ingredientsText?.lowercased() {
            for (ingredient, ingredientPenalty) in OpenFoodFactsService.shared.controversialIngredients {
                if ingredientsText.contains(ingredient) {
                    penalty += ingredientPenalty
                }
            }
        }
        
        return max(-15, penalty)
    }
    
    private func calculateBrandEthicsScore() -> Int {
        guard let brand = brands?.lowercased() else { return 0 }
        
        let ethicalBrands = [
            "patagonia": 10,
            "ben & jerry": 8,
            "seventh generation": 9,
            "tom's": 7,
            "the body shop": 6
        ]
        
        let unethicalBrands = [
            "nestlé": -10,
            "coca-cola": -8,
            "pepsi": -7,
            "monsanto": -15,
            "philip morris": -12
        ]
        
        for (ethicalBrand, score) in ethicalBrands {
            if brand.contains(ethicalBrand) {
                return score
            }
        }
        
        for (unethicalBrand, penalty) in unethicalBrands {
            if brand.contains(unethicalBrand) {
                return penalty
            }
        }
        
        return 0
    }
    
    private func analyzeEnhancedPackaging() -> (score: Int, type: Product.PackagingType) {
        if let materials = packagingMaterials, !materials.isEmpty {
            return analyzeRealMaterials(materials)
        }
        
        if let packagingText = packagingText, !packagingText.isEmpty {
            return analyzePackagingText(packagingText)
        }
        
        return inferPackagingFromProductInfo()
    }
    
    private func analyzeRealMaterials(_ materials: [String]) -> (score: Int, type: Product.PackagingType) {
        var totalScore = 0
        var materialCount = 0
        var detectedTypes: [Product.PackagingType] = []
        
        for material in materials {
            let cleanMaterial = material.replacingOccurrences(of: "en:", with: "")
                                        .replacingOccurrences(of: "fr:", with: "")
                                        .lowercased()
            
            for (materialKey, materialData) in OpenFoodFactsService.shared.packagingMaterialScores {
                if cleanMaterial.contains(materialKey) {
                    totalScore += materialData.score
                    detectedTypes.append(materialData.type)
                    materialCount += 1
                    break
                }
            }
        }
        
        guard materialCount > 0 else {
            return (50, .mixed)
        }
        
        let averageScore = totalScore / materialCount
        
        let typeCounts = Dictionary(grouping: detectedTypes, by: { $0 })
            .mapValues { $0.count }
        
        let predominantType = typeCounts.max { $0.value < $1.value }?.key ?? .mixed
        
        let adjustedScore = detectedTypes.count > 2 ? 
            averageScore - 10 :
            averageScore
        
        return (max(0, min(100, adjustedScore)), predominantType)
    }
    
    private func analyzePackagingText(_ text: String) -> (score: Int, type: Product.PackagingType) {
        let lowerText = text.lowercased()
        
        let patterns: [(pattern: String, score: Int, type: Product.PackagingType)] = [
            ("100% recyclable|fully recyclable", 85, .recyclable),
            ("recyclable", 75, .recyclable),
            ("compostable|biodegradable", 80, .compostable),
            ("reusable|refillable|returnable", 90, .reusable),
            ("glass|bottle made of glass", 88, .reusable),
            ("aluminum|tin can", 82, .recyclable),
            ("tetra pak|carton", 70, .mixed),
            ("plastic.*recyclable", 65, .recyclable),
            ("mixed materials|multi-material", 50, .mixed),
            ("non-recyclable", 30, .nonRecyclable),
            ("plastic.*film|plastic.*bag", 25, .nonRecyclable)
        ]
        
        for pattern in patterns {
            if lowerText.range(of: pattern.pattern, options: .regularExpression) != nil {
                return (pattern.score, pattern.type)
            }
        }
        
        return (50, .mixed)
    }
    
    private func inferPackagingFromProductInfo() -> (score: Int, type: Product.PackagingType) {
        let text = "\(productName ?? "") \(brands ?? "") \(categories ?? "")".lowercased()
        
        let productMappings: [(keywords: [String], score: Int, type: Product.PackagingType)] = [
            (["maruchan", "cup noodle", "instant soup"], 20, .nonRecyclable),
            (["sabritas", "doritos", "cheetos", "ruffles", "chips"], 15, .nonRecyclable),
            (["coca-cola", "pepsi", "soda can", "beer can"], 85, .recyclable),
            (["glass bottle", "beer bottle", "wine bottle"], 90, .reusable),
            (["water bottle", "pet bottle"], 70, .recyclable),
            (["milk carton", "juice carton", "tetra pak"], 65, .mixed),
            (["yogurt", "yoghurt"], 40, .mixed),
            (["cereal box"], 60, .recyclable),
            (["cookies", "chocolate bar", "candy"], 30, .nonRecyclable)
        ]
        
        for mapping in productMappings {
            for keyword in mapping.keywords {
                if text.contains(keyword) {
                    return (mapping.score, mapping.type)
                }
            }
        }
        
        return (50, .mixed)
    }
    
    private func calculateEnhancedEcoScore() -> Int {
        if let score = ecoscoreScore {
            return score
        }
        
        let carbonScore = calculateEnhancedCarbonScore()
        let ethicsScore = calculateEnhancedEthicsScore()
        let packagingInfo = analyzeEnhancedPackaging()
        let packagingScore = packagingInfo.score
        
        let weightedScore = Double(carbonScore) * 0.40 +
                           Double(packagingScore) * 0.35 +
                           Double(ethicsScore) * 0.25
        
        let adjustedScore = Int(weightedScore) + calculateEcoBonus()
        
        return max(0, min(100, adjustedScore))
    }
    
    private func calculateEcoBonus() -> Int {
        var bonus = 0
        
        if isLocalProduct() {
            bonus += 5
        }
        
        if let nutriGrade = nutriscoreGrade?.lowercased() {
            switch nutriGrade {
            case "a": bonus += 8
            case "b": bonus += 4
            case "c": bonus += 0
            case "d": bonus -= 4
            case "e": bonus -= 8
            default: break
            }
        }
        
        if let labels = labelsTags {
            let ecoLabels = ["organic", "fair-trade", "rainforest-alliance", 
                           "carbon-neutral", "vegan", "cruelty-free"]
            for label in ecoLabels {
                if labels.contains(label) {
                    bonus += 3
                }
            }
        }
        
        return bonus
    }
    
    private func parseEnhancedCertifications() -> [Product.Certification] {
        var certifications: [Product.Certification] = []
        
        if let labels = labelsTags {
            for label in labels {
                for (certKey, certData) in OpenFoodFactsService.shared.certificationWeights {
                    if label.contains(certKey) {
                        certifications.append(Product.Certification(
                            id: certKey,
                            name: certData.name,
                            description: certData.description
                        ))
                        break
                    }
                }
            }
        }
        
        if isLocalProduct() && !certifications.contains(where: { $0.id == "local" }) {
            certifications.append(Product.Certification(
                id: "local",
                name: "Local Product",
                description: "Produced locally, reducing transportation emissions"
            ))
        }
        
        return certifications
    }
    
    private func parseEnhancedMaterials() -> [Product.Material] {
        if let packagingMats = packagingMaterials, !packagingMats.isEmpty {
            return parseRealMaterials(packagingMats)
        }
        
        let packagingInfo = analyzeEnhancedPackaging()
        return inferMaterialsFromPackagingType(packagingInfo.type)
    }
    
    private func parseRealMaterials(_ materials: [String]) -> [Product.Material] {
        var materialDict: [String: (count: Int, recyclable: Bool)] = [:]
        
        for material in materials {
            let cleanMaterial = material.replacingOccurrences(of: "en:", with: "")
                .replacingOccurrences(of: "-", with: " ")
                .capitalized
            
            let isRecyclable = cleanMaterial.lowercased().contains("glass") ||
                             cleanMaterial.lowercased().contains("aluminum") ||
                             cleanMaterial.lowercased().contains("metal") ||
                             cleanMaterial.lowercased().contains("paper") ||
                             cleanMaterial.lowercased().contains("cardboard") ||
                             cleanMaterial.lowercased().contains("pet") ||
                             cleanMaterial.lowercased().contains("hdpe") ||
                             cleanMaterial.lowercased().contains("pp")
            
            materialDict[cleanMaterial, default: (0, isRecyclable)].count += 1
        }
        
        let total = Double(materialDict.values.reduce(0) { $0 + $1.count })
        
        return materialDict.map { (name, data) in
            let percentage = (Double(data.count) / total) * 100
            return Product.Material(
                name: name,
                percentage: percentage,
                isRecyclable: data.recyclable
            )
        }.sorted { $0.percentage > $1.percentage }
    }
    
    private func inferMaterialsFromPackagingType(_ type: Product.PackagingType) -> [Product.Material] {
        switch type {
        case .reusable:
            return [
                Product.Material(name: "Glass", percentage: 100, isRecyclable: true)
            ]
        case .recyclable:
            return [
                Product.Material(name: "PET Plastic", percentage: 60, isRecyclable: true),
                Product.Material(name: "Aluminum", percentage: 30, isRecyclable: true),
                Product.Material(name: "Paper", percentage: 10, isRecyclable: true)
            ]
        case .compostable:
            return [
                Product.Material(name: "Plant-based Materials", percentage: 100, isRecyclable: false)
            ]
        case .mixed:
            return [
                Product.Material(name: "Mixed Plastics", percentage: 50, isRecyclable: false),
                Product.Material(name: "Cardboard", percentage: 30, isRecyclable: true),
                Product.Material(name: "Aluminum Foil", percentage: 20, isRecyclable: false)
            ]
        case .nonRecyclable:
            return [
                Product.Material(name: "Multi-layer Plastic", percentage: 100, isRecyclable: false)
            ]
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case productNotFound
    case httpError(statusCode: Int)
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .productNotFound:
            return "Product not found"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError:
            return "Decoding error"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

struct OpenFoodFactsResponse: Codable {
    let status: Int
    let product: OpenFoodFactsProduct?
}

struct OpenFoodFactsProduct: Codable {
    let code: String?
    let productName: String?
    let brands: String?
    let categories: String?
    let imageUrl: String?
    let imageFrontUrl: String?
    let imageSmallUrl: String?
    
    let ecoscoreGrade: String?
    let ecoscoreScore: Int?
    let nutriscoreGrade: String?
    let nutriscoreScore: Int?
    let packagingMaterials: [String]?
    let packagingText: String?
    let ingredients: [Ingredient]?
    let ingredientsText: String?
    let labels: String?
    let labelsTags: [String]?
    let countries: String?
    let manufacturingPlaces: String?
    let origins: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case brands
        case categories
        case imageUrl = "image_url"
        case imageFrontUrl = "image_front_url"
        case imageSmallUrl = "image_small_url"
        case ecoscoreGrade = "ecoscore_grade"
        case ecoscoreScore = "ecoscore_score"
        case nutriscoreGrade = "nutriscore_grade"
        case nutriscoreScore = "nutriscore_score"
        case packagingMaterials = "packaging_materials_tags"
        case packagingText = "packaging_text"
        case ingredients
        case ingredientsText = "ingredients_text"
        case labels
        case labelsTags = "labels_tags"
        case countries
        case manufacturingPlaces = "manufacturing_places"
        case origins
    }
}

struct Ingredient: Codable {
    let id: String?
    let text: String?
    let vegan: String?
    let vegetarian: String?
}
