//
//  AddTransactionView.swift
//  BudgetTrack
//
//  Created by Baran on 19.03.2026.
//
import SwiftUI
import CoreLocation

struct AddTransactionView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory: Transaction.Category = .food
    @State private var selectedType: Transaction.TransactionType = .expense
    @State private var date = Date()
    @State private var isLoading = false
    @State private var useLocation = false
    
    var body: some View {
        NavigationStack {
            Form {
                // İşlem tipi
                Section {
                    Picker("Tip", selection: $selectedType) {
                        ForEach(Transaction.TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Detaylar
                Section("Detaylar") {
                    TextField("Başlık", text: $title)
                    
                    HStack {
                        Text("₺")
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                }
                
                // Kategori
                Section("Kategori") {
                    Picker("Kategori", selection: $selectedCategory) {
                        ForEach(Transaction.Category.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                }
                
                // Konum
                Section("Konum") {
                    Toggle("Konumu Kaydet", isOn: $useLocation)
                        .onChange(of: useLocation) { _, newValue in
                            if newValue {
                                locationManager.requestLocation()
                            }
                        }
                    
                    if useLocation {
                        if locationManager.locationName.isEmpty {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Konum alınıyor...")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                        } else {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                Text(locationManager.locationName)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .navigationTitle("İşlem Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        Task { await saveTransaction() }
                    }
                    .disabled(title.isEmpty || amount.isEmpty || isLoading)
                }
            }
        }
    }
    
    func saveTransaction() async {
        guard let amountDouble = Double(amount), amountDouble > 0 else { return }
        isLoading = true
        
        let transaction = Transaction(
            title: title,
            amount: amountDouble,
            date: date,
            category: selectedCategory,
            type: selectedType,
            location: useLocation ? locationManager.locationName : nil,
            latitude: useLocation ? locationManager.userLocation?.latitude : nil,
            longitude: useLocation ? locationManager.userLocation?.longitude : nil
        )
        
        await viewModel.addTransaction(transaction)
        isLoading = false
        dismiss()
    }
}

#Preview {
    AddTransactionView(viewModel: BudgetViewModel())
}
