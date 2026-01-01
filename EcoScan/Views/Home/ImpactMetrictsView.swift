import SwiftUI
struct ImpactMetricsView: View {
    @EnvironmentObject var productService: ProductService
    
    @State private var animatedCO2: Double = 0
    @State private var animatedPlastic: Double = 0
    @State private var animatedScans: Int = 0
    @State private var animatedDecisions: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                
                Text("Your Eco Impact")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    value: String(format: "%.1f", animatedCO2),
                    unit: "kg",
                    label: "CO₂ Saved",
                    icon: "cloud.fill",
                    color: .blue,
                    description: "≈ \(calculateTreesFromCO2()) trees"
                )
                
                MetricCard(
                    value: String(format: "%.1f", animatedPlastic),
                    unit: "kg",
                    label: "Plastic Avoided",
                    icon: "trash.slash.fill",
                    color: .green,
                    description: "≈ \(calculateBottlesFromPlastic()) bottles"
                )
                
                MetricCard(
                    value: "\(animatedScans)",
                    unit: "",
                    label: "Products Scanned",
                    icon: "barcode.viewfinder",
                    color: .orange,
                    description: "Last scan: \(lastScanTime)"
                )
                
                MetricCard(
                    value: "\(calculateEcoScorePercentage())",
                    unit: "%",
                    label: "Eco Score",
                    icon: "chart.bar.fill",
                    color: .purple,
                    description: "Your sustainability rate"
                )
            }
            
            if animatedScans > 0 {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Impact Breakdown")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        ImpactDetailRow(
                            metric: "Carbon Impact",
                            value: "\(String(format: "%.1f", animatedCO2)) kg CO₂",
                            comparison: "Like not driving \(calculateKmFromCO2()) km",
                            icon: "car.fill",
                            color: .blue
                        )
                        
                        ImpactDetailRow(
                            metric: "Waste Impact",
                            value: "\(String(format: "%.1f", animatedPlastic)) kg plastic",
                            comparison: "Like saving \(calculateBottlesFromPlastic()) water bottles",
                            icon: "drop.fill",
                            color: .green
                        )
                        
                        ImpactDetailRow(
                            metric: "Scan Activity",
                            value: "\(animatedScans) products",
                            comparison: "\(animatedDecisions) sustainable choices",
                            icon: "checkmark.circle.fill",
                            color: .orange
                        )
                        
                        ImpactDetailRow(
                            metric: "Sustainability Rate",
                            value: "\(calculateEcoScorePercentage())%",
                            comparison: "Better than \(calculateBetterThanPercentage())% of users",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .purple
                        )
                    }
                }
                .padding(.top, 8)
            }
            
            if animatedScans > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Progress Summary")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(progressMessage)
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Text("\(calculateEcoScorePercentage())% sustainable")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .onAppear {
            animateMetrics()
        }
        .onReceive(productService.$recentScans) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateMetrics()
            }
        }
    }
    
    
    private func calculateTreesFromCO2() -> Int {
        let trees = animatedCO2 / 21.0
        return max(1, Int(trees.rounded()))
    }
    
    private func calculateBottlesFromPlastic() -> Int {
        let bottles = animatedPlastic / 0.02
        return max(1, Int(bottles.rounded()))
    }
    
    private func calculateKmFromCO2() -> Int {
        let km = animatedCO2 / 0.2
        return max(1, Int(km.rounded()))
    }
    
    private func calculateEcoScorePercentage() -> Int {
        guard animatedScans > 0 else { return 0 }
        let percentage = Double(animatedDecisions) / Double(animatedScans) * 100.0
        return min(100, Int(percentage.rounded()))
    }
    
    private func calculateBetterThanPercentage() -> Int {
        let score = calculateEcoScorePercentage()
        switch score {
        case 0..<30: return 25
        case 30..<50: return 50
        case 50..<70: return 65
        case 70..<85: return 80
        case 85...100: return 90
        default: return 50
        }
    }
    
    private var progressMessage: String {
        let score = calculateEcoScorePercentage()
        switch score {
        case 0..<30:
            return "Keep going! Every eco choice counts."
        case 30..<50:
            return "Good start! You're making progress."
        case 50..<70:
            return "Well done! You're making a real impact."
        case 70..<85:
            return "Excellent! You're an eco champion!"
        case 85...100:
            return "Outstanding! You're leading the way!"
        default:
            return "Start scanning to see your impact!"
        }
    }
    
    private func animateMetrics() {
        let metrics = productService.getImpactMetrics()
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            animatedCO2 = metrics.co2Saved
            animatedPlastic = metrics.plasticSaved
            animatedScans = metrics.totalScans
            animatedDecisions = metrics.goodDecisions
        }
    }
    
    private var lastScanTime: String {
        guard let lastScan = productService.recentScans.first else {
            return "Never"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastScan.scanDate, relativeTo: Date())
    }
}

struct ImpactDetailRow: View {
    let metric: String
    let value: String
    let comparison: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(metric)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(value)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                }
                
                Text(comparison)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

struct MetricCard: View {
    let value: String
    let unit: String
    let label: String
    let icon: String
    let color: Color
    let description: String?
    
    @State private var isVisible = false
    @State private var isPulsing = false
    
    init(value: String, unit: String, label: String, icon: String, color: Color, description: String? = nil) {
        self.value = value
        self.unit = unit
        self.label = label
        self.icon = icon
        self.color = color
        self.description = description
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(isPulsing ? 0.3 : 0.15))
                    .frame(width: 60, height: 60)
                    .scaleEffect(isPulsing ? 1.1 : 1.0)
                
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 2)
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(color.opacity(0.7))
                        .offset(y: -2)
                }
            }
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            if let description = description {
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: color.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .scaleEffect(isVisible ? 1 : 0.9)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                isVisible = true
            }
        }
    }
}

extension Color {
    static let ecoGreen = Color(red: 0.2, green: 0.6, blue: 0.4)
    static let ecoBlue = Color(red: 0.2, green: 0.5, blue: 0.7)
    static let ecoOrange = Color.orange
    static let ecoPurple = Color.purple
}
