import SwiftUI

struct ProductInfoView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("Eco-Friendly Products Guide")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Learn about environmental impact")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Eco Score Guide")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("How we rate products from 0-100")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            ScoreRange(range: "0-40", label: "Poor", color: .red)
                            ScoreRange(range: "41-60", label: "Fair", color: .orange)
                            ScoreRange(range: "61-70", label: "Good", color: .yellow)
                            ScoreRange(range: "71-85", label: "Very Good", color: .green)
                            ScoreRange(range: "86-100", label: "Excellent", color: Color(red: 0.1, green: 0.8, blue: 0.3))
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Packaging Types")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("Understanding different packaging materials")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            ForEach(Product.PackagingType.allCases, id: \.self) { type in
                                PackagingTypeCard(type: type)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Common Materials")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("Recyclability of common packaging")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            MaterialCard(
                                name: "PET Plastic",
                                recyclable: true,
                                description: "Widely recycled, often used for bottles",
                                materialIcon: "drop.fill"
                            )
                            MaterialCard(
                                name: "Glass",
                                recyclable: true,
                                description: "Infinitely recyclable, energy intensive",
                                materialIcon: "cube.transparent.fill"
                            )
                            MaterialCard(
                                name: "Aluminum",
                                recyclable: true,
                                description: "Highly recyclable, saves 95% energy",
                                materialIcon: "cylinder.fill"
                            )
                            MaterialCard(
                                name: "Paper/Cardboard",
                                recyclable: true,
                                description: "Biodegradable, widely recycled",
                                materialIcon: "doc.fill"
                            )
                            MaterialCard(
                                name: "PVC Plastic",
                                recyclable: false,
                                description: "Difficult to recycle, avoid when possible",
                                materialIcon: "exclamationmark.triangle.fill"
                            )
                            MaterialCard(
                                name: "Compostable Plastic",
                                recyclable: false,
                                description: "Breaks down in industrial composters",
                                materialIcon: "leaf.fill"
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Eco Certifications")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("Recognized environmental labels")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            CertificationCard(
                                name: "Fair Trade",
                                description: "Ethical sourcing, fair wages",
                                icon: "hand.raised.fill",
                                iconColor: .orange
                            )
                            CertificationCard(
                                name: "Organic",
                                description: "No synthetic pesticides or fertilizers",
                                icon: "leaf.fill",
                                iconColor: .green
                            )
                            CertificationCard(
                                name: "FSC Certified",
                                description: "Responsibly sourced wood/paper",
                                icon: "tree.fill",
                                iconColor: .brown
                            )
                            CertificationCard(
                                name: "Rainforest Alliance",
                                description: "Biodiversity and sustainability",
                                icon: "bird.fill",
                                iconColor: .green
                            )
                            CertificationCard(
                                name: "Carbon Neutral",
                                description: "Net-zero carbon emissions",
                                icon: "cloud.fill",
                                iconColor: .blue
                            )
                            CertificationCard(
                                name: "Cruelty Free",
                                description: "No animal testing",
                                icon: "pawprint.fill",
                                iconColor: .pink
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Tips for Eco Shopping")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        VStack(spacing: 12) {
                            TipCard(tip: "Choose products with minimal packaging")
                            TipCard(tip: "Look for recyclable or compostable materials")
                            TipCard(tip: "Support local products to reduce transportation")
                            TipCard(tip: "Buy in bulk to reduce packaging waste")
                            TipCard(tip: "Choose refillable containers when possible")
                            TipCard(tip: "Avoid single-use plastics")
                            TipCard(tip: "Check for eco-certifications")
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sources")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("Information based on data from:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("• Open Food Facts Database\n• EPA Recycling Guidelines\n• World Wildlife Fund\n• Environmental Working Group")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.bottom, 20)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGroupedBackground),
                        Color(.systemGroupedBackground).opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Information")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PackagingTypeCard: View {
    let type: Product.PackagingType
    
    var typeInfo: (icon: String, color: Color, description: String) {
        switch type {
        case .recyclable:
            return ("arrow.3.trianglepath", .blue, "Can be recycled and reused")
        case .compostable:
            return ("leaf.fill", .green, "Decomposes naturally")
        case .reusable:
            return ("repeat", .purple, "Designed for multiple uses")
        case .nonRecyclable:
            return ("trash.fill", .red, "Cannot be easily recycled")
        case .mixed:
            return ("square.stack.3d.up.fill", .orange, "Combination of materials")
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: typeInfo.icon)
                .font(.title2)
                .foregroundColor(typeInfo.color)
                .frame(width: 40)
                .background(
                    Circle()
                        .fill(typeInfo.color.opacity(0.1))
                        .frame(width: 50, height: 50)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(typeInfo.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ScoreRange: View {
    let range: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(range)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 70, alignment: .leading)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(height: 8)
            
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 100, alignment: .trailing)
        }
    }
}

struct CertificationCard: View {
    let name: String
    let description: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MaterialCard: View {
    let name: String
    let recyclable: Bool
    let description: String
    let materialIcon: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(recyclable ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: materialIcon)
                    .font(.title2)
                    .foregroundColor(recyclable ? .green : .red)
                
                Image(systemName: recyclable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(recyclable ? Color.green : Color.red)
                            .frame(width: 16, height: 16)
                    )
                    .offset(x: 18, y: 18)
            }
            .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct TipCard: View {
    let tip: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
            
            Text(tip)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ProductInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProductInfoView()
    }
}
