import SwiftUI

struct HistoryDetailView: View {
    let scan: ScanHistory
    @Environment(\.dismiss) private var dismiss
    
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
                        headerSection
                        
                    
                        EcoScoreDetailView(score: scan.ecoScore)
                        
                        scoresBreakdown
                        
                        decisionSection
                        
                        impactSection
                        
                        productDetailsSection
                        
                        environmentalFactsSection
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Scan Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                    .fontWeight(.medium)
                }
            }
        }
    }
    
   
  
    private var headerSection: some View {
        VStack(spacing: 12) {
            if let imageUrl = scan.imageUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .cornerRadius(12)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }
            }
            
            VStack(spacing: 6) {
                Text(scan.productName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                if let brand = scan.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let category = scan.category {
                    Text(category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.1))
                        .cornerRadius(12)
                }
            }
            
            Text("Scanned \(formattedDate)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
    
    private var scoresBreakdown: some View {
        VStack(spacing: 16) {
            Text("Score Breakdown")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 14) {
                ScoreBar(label: "Packaging", score: scan.packagingScore, color: Color(red: 0.2, green: 0.6, blue: 0.4))
                ScoreBar(label: "Carbon Footprint", score: scan.carbonScore, color: Color(red: 0.3, green: 0.7, blue: 0.5))
                ScoreBar(label: "Ethics", score: scan.ethicsScore, color: Color(red: 0.15, green: 0.55, blue: 0.45))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
    
    private var decisionSection: some View {
        VStack(spacing: 12) {
            Text("Your Decision")
                .font(.headline)
            
            HStack {
                Image(systemName: scan.decision.icon)
                    .font(.title2)
                    .foregroundColor(scan.decision.color)
                
                Text(scan.decision.rawValue)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(scan.decision.color)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(scan.decision.color.opacity(0.15))
            .cornerRadius(16)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
    
    private var impactSection: some View {
        VStack(spacing: 16) {
            Text("Environmental Impact")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                ImpactMetric(
                    value: String(format: "%.2f", calculatedCO2Impact),
                    unit: "kg CO₂",
                    label: scan.decision == .avoided || scan.decision == .alternative ? "Saved" : "Emitted",
                    icon: "cloud.fill",
                    color: scan.decision == .avoided || scan.decision == .alternative ? Color(red: 0.2, green: 0.6, blue: 0.4) : .orange
                )
                
                ImpactMetric(
                    value: String(format: "%.2f", calculatedPlasticImpact),
                    unit: "kg",
                    label: scan.packagingType == .recyclable || scan.packagingType == .compostable ? "Recyclable" : "Waste",
                    icon: "trash.fill",
                    color: scan.packagingType == .recyclable || scan.packagingType == .compostable ? Color(red: 0.2, green: 0.6, blue: 0.4) : .red
                )
            }
            
            if scan.decision == .avoided || scan.decision == .alternative {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                    Text("Great choice! You're helping the environment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(red: 0.2, green: 0.6, blue: 0.4).opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
    
    private var productDetailsSection: some View {
        VStack(spacing: 16) {
            DetailCard(
                title: "Packaging",
                icon: "shippingbox.fill",
                iconColor: packagingColor
            ) {
                Text(scan.packagingType.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !scan.materials.isEmpty {
                DetailCard(
                    title: "Materials",
                    icon: "cube.fill",
                    iconColor: Color(red: 0.2, green: 0.6, blue: 0.4)
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(scan.materials, id: \.name) { material in
                            HStack {
                                Image(systemName: material.isRecyclable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(material.isRecyclable ? .green : .red)
                                    .font(.caption)
                                
                                Text(material.name)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("\(Int(material.percentage))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            if !scan.certifications.isEmpty {
                DetailCard(
                    title: "Certifications",
                    icon: "checkmark.seal.fill",
                    iconColor: Color(red: 0.2, green: 0.6, blue: 0.4)
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(scan.certifications, id: \.id) { cert in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(cert.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(cert.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var environmentalFactsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Environmental Insights")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(environmentalFacts, id: \.self) { fact in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                            .font(.caption)
                        
                        Text(fact)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
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
        .padding(.horizontal, 20)
    }
    
    private var calculatedCO2Impact: Double {
        let baseImpact = Double(100 - scan.ecoScore) * 0.015
        
        if scan.decision == .avoided || scan.decision == .alternative {
            return baseImpact
        } else {
            return baseImpact * -1
        }
    }
    
    private var calculatedPlasticImpact: Double {
        let plasticMaterials = scan.materials.filter { $0.name.contains("Plastic") || $0.name.contains("PET") }
        let totalPlastic = plasticMaterials.reduce(0.0) { $0 + $1.percentage }
        
        return totalPlastic * 0.002
    }
    
    private var packagingColor: Color {
        switch scan.packagingType {
        case .recyclable, .compostable, .reusable:
            return Color(red: 0.2, green: 0.6, blue: 0.4)
        case .mixed:
            return .orange
        case .nonRecyclable:
            return .red
        }
    }
    
    private var environmentalFacts: [String] {
        var facts: [String] = []
        
        if scan.ecoScore >= 70 {
            facts.append("This product has an excellent environmental score")
        } else if scan.ecoScore < 40 {
            facts.append("Consider looking for more sustainable alternatives")
        }
        
        if scan.packagingType == .recyclable || scan.packagingType == .compostable {
            facts.append("The packaging can be properly recycled or composted")
        } else if scan.packagingType == .nonRecyclable {
            facts.append("This packaging is difficult to recycle and may end up in landfills")
        }
        
        if scan.isLocal {
            facts.append("Supporting local products reduces transportation emissions")
        }
        
        if !scan.certifications.isEmpty {
            facts.append("Product has \(scan.certifications.count) environmental certification(s)")
        }
        
        let recyclableMaterials = scan.materials.filter { $0.isRecyclable }
        if !recyclableMaterials.isEmpty {
            let percentage = Int(recyclableMaterials.reduce(0.0) { $0 + $1.percentage })
            facts.append("\(percentage)% of materials are recyclable")
        }
        
        if scan.decision == .avoided || scan.decision == .alternative {
            facts.append("Your sustainable choice helps reduce waste and carbon emissions")
        }
        
        return facts
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: scan.scanDate)
    }
}


struct ScoreBar: View {
    let label: String
    let score: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(score)/100")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.15))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(score) / 100, height: 10)
                }
            }
            .frame(height: 10)
        }
    }
}

struct ImpactMetric: View {
    let value: String
    let unit: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.05))
        )
    }
}

struct DetailCard<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.headline)
            }
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
}


struct EcoScoreDetailView: View {
    let score: Int
    
    var scoreColor: Color {
        switch score {
        case 0..<40: return .red
        case 40..<60: return .orange
        case 60..<80: return .yellow
        default: return Color(red: 0.2, green: 0.6, blue: 0.4)
        }
    }
    
    var scoreLabel: String {
        switch score {
        case 0..<40: return "Needs Improvement"
        case 40..<60: return "Fair"
        case 60..<80: return "Good"
        default: return "Excellent"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(scoreColor.opacity(0.2), lineWidth: 14)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: scoreColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    .animation(.easeInOut, value: score)
                
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor)
                    
                    Text("ECO SCORE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(scoreLabel)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(scoreColor)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
}
