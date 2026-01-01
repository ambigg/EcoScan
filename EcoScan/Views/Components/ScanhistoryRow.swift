import SwiftUI

struct ScanHistoryRow: View {
    let scan: ScanHistory
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(scoreColor.opacity(0.2), lineWidth: 3)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: CGFloat(scan.ecoScore) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text("\(scan.ecoScore)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(scoreColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(scan.productName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                if let brand = scan.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: scan.decision.icon)
                        .font(.caption2)
                        .foregroundColor(scan.decision.color)
                    
                    Text(scan.decision.rawValue)
                        .font(.caption2)
                        .foregroundColor(scan.decision.color)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(relativeDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var scoreColor: Color {
        switch scan.ecoScore {
        case 0..<40: return .red
        case 40..<60: return .orange
        case 60..<80: return .yellow
        default: return .green
        }
    }
    
    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: scan.scanDate, relativeTo: Date())
    }
}


struct ScanHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            if let yogurt = Product.demoProducts["8901234567890"] {
                ScanHistoryRow(scan: ScanHistory(
                    product: yogurt,
                    decision: .purchased
                ))
            }
            
            if let water = Product.demoProducts["8901234567891"] {
                ScanHistoryRow(scan: ScanHistory(
                    product: water,
                    decision: .avoided
                ))
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
