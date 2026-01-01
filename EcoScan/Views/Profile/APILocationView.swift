import SwiftUI

struct APILocationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    @ObservedObject var productService: ProductService
    
    @State private var selectedCountry: String
    @State private var showingConfirmation = false
    
    private let openFoodFactsService = OpenFoodFactsService.shared
    
    init(productService: ProductService) {
        self.productService = productService
        let currentCountry = OpenFoodFactsService.shared.getCurrentCountry()
        _selectedCountry = State(initialValue: currentCountry.code)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(openFoodFactsService.getAvailableCountries(), id: \.code) { country in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(country.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                if country.code != "world" {
                                    Text("api.\(country.code).openfoodfacts.org")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("api.world.openfoodfacts.org")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedCountry == country.code {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.ecoGreen)
                                    .font(.body)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCountry = country.code
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Select API Location")
                } footer: {
                    Text("Changing the API location may affect product availability and data. Products from your selected country will be prioritized.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("Current Location")
                                .font(.body)
                        } icon: {
                            Image(systemName: "network")
                                .foregroundColor(.blue)
                        }
                        
                        Text("Using: \(getCurrentCountryName())")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if selectedCountry != openFoodFactsService.getCurrentCountry().code {
                            Text("Will change to: \(getSelectedCountryName())")
                                .font(.subheadline)
                                .foregroundColor(.ecoGreen)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("API Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveLocation()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedCountry == openFoodFactsService.getCurrentCountry().code)
                }
            }
            .alert("Change API Location", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Change", role: .none) {
                    confirmChangeLocation()
                }
            } message: {
                Text("Changing the API location to \(getSelectedCountryName()) will affect future product searches. Continue?")
            }
        }
    }
    
    private func getCurrentCountryName() -> String {
        openFoodFactsService.getCurrentCountry().name
    }
    
    private func getSelectedCountryName() -> String {
        openFoodFactsService.getAvailableCountries()
            .first { $0.code == selectedCountry }?.name ?? "Unknown"
    }
    
    private func saveLocation() {
        showingConfirmation = true
    }
    
    private func confirmChangeLocation() {
        openFoodFactsService.setCountry(selectedCountry)
        
        if var user = authService.currentUser {
            var preferences = user.preferences
            preferences.openFoodFactsCountry = selectedCountry
            authService.updatePreferences(preferences)
        }
        
        productService.clearCache()
        
        dismiss()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }}
