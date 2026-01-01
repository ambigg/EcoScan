import SwiftUI

struct EcoScoreView: View {
    let score: Int
    let product: Product
    
  
    private var safeScore: Int {
        min(100, max(0, score))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Overall Eco Score")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
          
            ZStack {
               
                Circle()
                    .stroke(scoreColor.opacity(0.15), lineWidth: 20)
                    .frame(width: 180, height: 180)
                
               
                Circle()
                    .trim(from: 0, to: CGFloat(safeScore) / 100)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                scoreColor.opacity(0.8),
                                scoreColor
                            ]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: scoreColor.opacity(0.3), radius: 10, x: 0, y: 5)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: safeScore)
                
               
                VStack(spacing: 4) {
                    Text("\(safeScore)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor)
                    
                    Text("out of 100")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(scoreCategory)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(scoreColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(scoreColor.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            
           
            VStack(spacing: 12) {
                Text("What this score means")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(scoreExplanation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
            }
            .padding(.top, 8)
            
           
            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    VStack(spacing: 6) {
                        Rectangle()
                            .fill(scaleColor(for: index))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Text(scaleLabel(for: index))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var scoreColor: Color {
        switch safeScore {
        case 0..<40: return .red
        case 40..<60: return .orange
        case 60..<80: return .yellow
        default: return .green
        }
    }
    
    private var scoreCategory: String {
        switch safeScore {
        case 0..<40: return "Needs Improvement"
        case 40..<60: return "Fair"
        case 60..<80: return "Good"
        default: return "Excellent"
        }
    }
    
    private var scoreExplanation: String {
        switch safeScore {
        case 0..<40:
            return "This product has significant environmental impact. Consider alternatives with better packaging, lower carbon footprint, or ethical certifications."
        case 40..<60:
            return "Average environmental performance. There are likely better options available. Check breakdown for improvement areas."
        case 60..<80:
            return "Good environmental choice. This product performs well in key sustainability metrics."
        default:
            return "Excellent sustainable choice! This product excels in packaging, carbon footprint, and ethical practices."
        }
    }
    
    private func scaleColor(for index: Int) -> Color {
        switch index {
        case 0: return .red
        case 1: return .orange
        case 2: return .yellow
        case 3: return Color(red: 0.6, green: 0.8, blue: 0.3)
        case 4: return .green
        default: return .gray
        }
    }
    
    private func scaleLabel(for index: Int) -> String {
        switch index {
        case 0: return "0-20"
        case 1: return "21-40"
        case 2: return "41-60"
        case 3: return "61-80"
        case 4: return "81-100"
        default: return ""
        }
    }
}


struct SimpleEcoScoreView: View {
    let score: Int
    
    var body: some View {
        EcoScoreView(score: score, product: Product.demoProducts.first!.value)
    }
}
