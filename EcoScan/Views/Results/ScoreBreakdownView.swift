import SwiftUI

struct ScoreBreakdownView: View {
    let product: Product
    
   
    private var packagingScore: Int {
        min(100, max(0, product.packagingScore))
    }
    
    private var carbonScore: Int {
        min(100, max(0, product.carbonScore))
    }
    
    private var ethicsScore: Int {
        min(100, max(0, product.ethicsScore))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Scientific Breakdown")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                EnhancedScoreRow(
                    title: "Packaging",
                    score: packagingScore,
                    icon: "shippingbox.fill",
                    color: .blue,
                    factors: getPackagingFactors()
                )
                
                EnhancedScoreRow(
                    title: "Carbon Footprint",
                    score: carbonScore,
                    icon: "leaf.fill",
                    color: .green,
                    factors: getCarbonFactors()
                )
                
                EnhancedScoreRow(
                    title: "Ethics & Labor",
                    score: ethicsScore,
                    icon: "heart.fill",
                    color: .orange,
                    factors: getEthicsFactors()
                )
            }
            
           
            VStack(alignment: .leading, spacing: 8) {
                Text(" How we calculate")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Scores are based on IPCC carbon data, FAO food impact studies, and Mexico's specific recycling regulations (SEMARNAT).")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private func getPackagingFactors() -> [String] {
        var factors: [String] = []
        
       
        let recyclablePercentage = product.materials.filter { $0.isRecyclable }.reduce(0) { $0 + $1.percentage }
        factors.append("\(Int(recyclablePercentage))% recyclable materials")
        
      
        switch product.packagingType {
        case .recyclable:
            factors.append("Fully recyclable in Mexico")
        case .compostable:
            factors.append("Compostable/biodegradable")
        case .reusable:
            factors.append("Designed for reuse")
        case .nonRecyclable:
            factors.append("Not recyclable in MX")
        case .mixed:
            factors.append("Mixed materials (hard to recycle)")
        }
        
        // Material count
        if product.materials.count > 2 {
            factors.append("\(product.materials.count) materials (complex)")
        }
        
        return factors
    }
    
    private func getCarbonFactors() -> [String] {
        var factors: [String] = []
        
        // Category impact
        let category = product.category.lowercased()
        if category.contains("meat") || category.contains("beef") {
            factors.append("High-impact category (meat)")
        } else if category.contains("plant") || category.contains("vegetable") {
            factors.append("Low-impact category (plant-based)")
        }
        
      
        if product.isLocal {
            factors.append("Produced locally (lower transport)")
        } else {
            factors.append("Imported (higher transport impact)")
        }
        
        // Processing
        if category.contains("processed") || category.contains("ultra-processed") {
            factors.append("Highly processed")
        } else if category.contains("fresh") || category.contains("raw") {
            factors.append("Fresh/raw (low processing)")
        }
        
        return factors
    }
    
    private func getEthicsFactors() -> [String] {
        var factors: [String] = []
        
        // Certifications
        if !product.certifications.isEmpty {
            factors.append("\(product.certifications.count) ethical certification(s)")
            product.certifications.prefix(2).forEach { cert in
                factors.append("• \(cert.name)")
            }
        } else {
            factors.append("No ethical certifications")
        }
        
        // Brand practices (simplified)
        if let brand = product.brand?.lowercased() {
            let ethicalBrands = ["patagonia", "seventh generation", "ben & jerry", "the body shop"]
            let unethicalBrands = ["nestlé", "monsanto", "philip morris"]
            
            if ethicalBrands.contains(where: { brand.contains($0) }) {
                factors.append("Known ethical brand")
            } else if unethicalBrands.contains(where: { brand.contains($0) }) {
                factors.append("Brand with ethical concerns")
            }
        }
        
        return factors
    }
}

struct EnhancedScoreRow: View {
    let title: String
    let score: Int
    let icon: String
    let color: Color
    let factors: [String]
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(scoreLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(score)/100")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(scoreColor)
                    
                    Text(scoreCategory)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Score bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(score) / 100, height: 8)
                }
            }
            .frame(height: 8)
            
            // Expandable factors
            if !factors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Factors considered")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(factors, id: \.self) { factor in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 4))
                                        .foregroundColor(color)
                                        .padding(.top, 6)
                                    
                                    Text(factor)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var scoreColor: Color {
        switch score {
        case 0..<40: return .red
        case 40..<60: return .orange
        case 60..<80: return .yellow
        default: return .green
        }
    }
    
    private var scoreCategory: String {
        switch score {
        case 0..<40: return "Poor"
        case 40..<60: return "Fair"
        case 60..<80: return "Good"
        default: return "Excellent"
        }
    }
    
    private var scoreLabel: String {
        switch title {
        case "Packaging": return "Materials & recyclability"
        case "Carbon Footprint": return "Environmental impact"
        case "Ethics & Labor": return "Fair practices"
        default: return ""
        }
    }
}
