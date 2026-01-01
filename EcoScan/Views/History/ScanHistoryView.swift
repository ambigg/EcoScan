import SwiftUI

struct ScanHistoryView: View {
    @EnvironmentObject var productService: ProductService
    @State private var selectedScan: ScanHistory?
    @State private var searchText = ""
    @State private var filterDecision: ScanHistory.UserDecision?
    @State private var sortOrder: SortOrder = .dateDescending
    
    enum SortOrder: String, CaseIterable {
        case dateDescending = "Recent First"
        case dateAscending = "Oldest First"
        case scoreDescending = "Highest Score"
        case scoreAscending = "Lowest Score"
    }
    
    var filteredScans: [ScanHistory] {
        var scans = productService.recentScans
        
        if !searchText.isEmpty {
            scans = scans.filter { scan in
                scan.productName.localizedCaseInsensitiveContains(searchText) ||
                (scan.brand?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if let decision = filterDecision {
            scans = scans.filter { $0.decision == decision }
        }
        
        switch sortOrder {
        case .dateDescending:
            scans.sort { $0.scanDate > $1.scanDate }
        case .dateAscending:
            scans.sort { $0.scanDate < $1.scanDate }
        case .scoreDescending:
            scans.sort { $0.ecoScore > $1.ecoScore }
        case .scoreAscending:
            scans.sort { $0.ecoScore < $1.ecoScore }
        }
        
        return scans
    }
    
    var body: some View {
        NavigationView {
            Group {
                if productService.recentScans.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            statsSection
                            
                            filterSection
                            
                            historyList
                        }
                        .padding(.vertical)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Scan History")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search products")
            .sheet(item: $selectedScan) { scan in
                HistoryDetailView(scan: scan)
            }
        }
    }
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Total Scans",
                    value: "\(productService.recentScans.count)",
                    icon: "barcode.viewfinder",
                    color: .blue
                )
                
                StatCard(
                    title: "Avg Score",
                    value: "\(averageScore)",
                    icon: "chart.bar.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 12) {
                StatCard(
                    title: "Good Choices",
                    value: "\(goodChoices)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "CO₂ Saved",
                    value: String(format: "%.1f kg", totalCO2Saved),
                    icon: "leaf.fill",
                    color: .mint
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(
                        title: "All",
                        isSelected: filterDecision == nil,
                        action: { filterDecision = nil }
                    )
                    
                    ForEach([ScanHistory.UserDecision.purchased, .avoided, .alternative, .undecided], id: \.self) { decision in
                        FilterChip(
                            title: decision.rawValue,
                            isSelected: filterDecision == decision,
                            action: { filterDecision = decision }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            HStack {
                Text("Sort by:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Sort", selection: $sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(.menu)
                .tint(.green)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    private var historyList: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredScans) { scan in
                EnhancedScanHistoryCard(scan: scan)
                    .onTapGesture {
                        selectedScan = scan
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteScan(scan)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No scan history")
                .font(.headline)
            
            Text("Your scan history will appear here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var averageScore: Int {
        guard !productService.recentScans.isEmpty else { return 0 }
        let total = productService.recentScans.reduce(0) { $0 + $1.ecoScore }
        return total / productService.recentScans.count
    }
    
    private var goodChoices: Int {
        productService.recentScans.filter { $0.decision == .avoided || $0.decision == .alternative }.count
    }
    
    private var totalCO2Saved: Double {
        productService.recentScans.reduce(0.0) { total, scan in
            if scan.decision == .avoided || scan.decision == .alternative {
                return total + (Double(100 - scan.ecoScore) * 0.01)
            }
            return total
        }
    }
    
    private func deleteScan(_ scan: ScanHistory) {
        if let index = productService.recentScans.firstIndex(where: { $0.id == scan.id }) {
            productService.recentScans.remove(at: index)
            productService.saveToUserDefaults()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.green : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

struct EnhancedScanHistoryCard: View {
    let scan: ScanHistory
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(scoreColor.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: CGFloat(scan.ecoScore) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("\(scan.ecoScore)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor)
                    Text("ECO")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(scan.productName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                if let brand = scan.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Label(scan.decision.rawValue, systemImage: scan.decision.icon)
                        .font(.caption)
                        .foregroundColor(scan.decision.color)
                    
                    if let category = scan.category {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var scoreColor: Color {
        switch scan.ecoScore {
        case 0..<40: return .red
        case 40..<60: return .orange
        case 60..<80: return .yellow
        default: return .green
        }
    }
    
    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: scan.scanDate, relativeTo: Date())
    }
}
