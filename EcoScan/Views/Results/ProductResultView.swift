import SwiftUI

struct ProductResultView: View {
    let product: Product
    @EnvironmentObject var productService: ProductService
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDecision: ScanHistory.UserDecision?
    @State private var hasSaved = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    EcoScoreView(score: product.ecoScore, product: product)
                        .padding(.top)
                    
                    productInfoView
                    
                    ScoreBreakdownView(product: product)
                        .padding(.horizontal)
                    
                    decisionButtonsView
                        .padding(.horizontal)
                    
                    if !product.certifications.isEmpty {
                        certificationsView
                            .padding(.horizontal)
                    }
                    
                    materialsView
                        .padding(.horizontal)
                    
                    environmentalImpactView
                        .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Scan Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var productInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageUrl = product.imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        productPlaceholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                            .cornerRadius(12)
                    case .failure:
                        productPlaceholder
                    @unknown default:
                        productPlaceholder
                    }
                }
            } else {
                productPlaceholder
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name.isEmpty ? "Unknown Product" : product.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let brand = product.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Label(product.category, systemImage: "tag.fill")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(12)
                    
                    if product.isLocal {
                        Label("Local", systemImage: "location.fill")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }
                    
                    Label(product.packagingType.rawValue, systemImage: packageIcon)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(packageColor.opacity(0.1))
                        .foregroundColor(packageColor)
                        .cornerRadius(12)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .padding(.horizontal)
    }
    
    private var productPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .frame(height: 120)
            .overlay(
                VStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No image available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            )
    }
    
    private var packageIcon: String {
        switch product.packagingType {
        case .recyclable: return "arrow.3.trianglepath"
        case .compostable: return "leaf.fill"
        case .reusable: return "repeat"
        case .nonRecyclable: return "trash.fill"
        case .mixed: return "square.stack.3d.up.fill"
        }
    }
    
    private var packageColor: Color {
        switch product.packagingType {
        case .recyclable, .compostable, .reusable: return .green
        case .mixed: return .orange
        case .nonRecyclable: return .red
        }
    }
    
    private var decisionButtonsView: some View {
        VStack(spacing: 16) {
            Text("What did you decide?")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(ScanHistory.UserDecision.allCases, id: \.self) { decision in
                    DecisionButton(
                        title: decision.rawValue,
                        icon: decision.icon,
                        isSelected: selectedDecision == decision,
                        color: decision.color
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDecision = decision
                            saveAndDismiss(decision: decision)
                        }
                    }
                    .disabled(hasSaved)
                }
            }
            
            if hasSaved {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Saved successfully!")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private func saveAndDismiss(decision: ScanHistory.UserDecision) {
        guard !hasSaved else { return }
        
        hasSaved = true
        productService.saveScan(product: product, decision: decision)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
    
    private var certificationsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Certifications")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(product.certifications, id: \.id) { cert in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cert.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(cert.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var materialsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Materials")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 10) {
                ForEach(product.materials, id: \.name) { material in
                    HStack(spacing: 12) {
                        Image(systemName: material.isRecyclable ? "arrow.3.trianglepath" : "trash.fill")
                            .foregroundColor(material.isRecyclable ? .green : .red)
                            .font(.caption)
                            .frame(width: 20)
                        
                        Text(material.name)
                            .font(.subheadline)
                            .frame(width: 80, alignment: .leading)
                        
                        Spacer()
                        
                        Text("\(Int(material.percentage))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                            .frame(width: 40)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(material.isRecyclable ? Color.green : Color.red)
                                    .frame(width: geometry.size.width * CGFloat(material.percentage / 100), height: 4)
                            }
                        }
                        .frame(width: 60, height: 4)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var environmentalImpactView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Environmental Impact")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ImpactRow(
                    icon: "leaf.fill",
                    title: "Overall Score",
                    value: "\(product.ecoScore)/100",
                    color: scoreColor(product.ecoScore)
                )
                
                ImpactRow(
                    icon: "shippingbox.fill",
                    title: "Packaging",
                    value: "\(product.packagingScore)/100",
                    color: scoreColor(product.packagingScore)
                )
                
                ImpactRow(
                    icon: "cloud.fill",
                    title: "Carbon",
                    value: "\(product.carbonScore)/100",
                    color: scoreColor(product.carbonScore)
                )
                
                ImpactRow(
                    icon: "heart.fill",
                    title: "Ethics",
                    value: "\(product.ethicsScore)/100",
                    color: scoreColor(product.ethicsScore)
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 0..<40: return .red
        case 40..<60: return .orange
        case 60..<80: return .yellow
        default: return .green
        }
    }
}

struct DecisionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 30)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(color)
                        .transition(.scale)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                    )
            )
            .foregroundColor(isSelected ? color : .primary)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isSelected) 
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct ImpactRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

