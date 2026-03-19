//
//  ChartsView.swift
//  BudgetTrack
//
//  Created by Baran on 20.03.2026.
//
import SwiftUI
import Charts

struct ChartsView: View {
    @ObservedObject var viewModel: BudgetViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Gelir vs Gider
                VStack(alignment: .leading, spacing: 12) {
                    Text("Gelir vs Gider")
                        .font(.headline)
                    
                    Chart {
                        BarMark(
                            x: .value("Tip", "Gelir"),
                            y: .value("Miktar", viewModel.totalIncome)
                        )
                        .foregroundStyle(.green)
                        
                        BarMark(
                            x: .value("Tip", "Gider"),
                            y: .value("Miktar", viewModel.totalExpense)
                        )
                        .foregroundStyle(.red)
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.06), radius: 6)
                }
                
                // Kategoriye göre harcamalar
                if !viewModel.expensesByCategory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Kategoriye Göre Harcama")
                            .font(.headline)
                        
                        Chart(viewModel.expensesByCategory, id: \.category) { item in
                            SectorMark(
                                angle: .value("Miktar", item.amount),
                                innerRadius: .ratio(0.6)
                            )
                            .foregroundStyle(by: .value("Kategori", item.category.rawValue))
                        }
                        .frame(height: 250)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.06), radius: 6)
                        
                        // Legend
                        ForEach(viewModel.expensesByCategory, id: \.category) { item in
                            HStack {
                                Image(systemName: item.category.icon)
                                    .foregroundStyle(.blue)
                                Text(item.category.rawValue)
                                    .font(.subheadline)
                                Spacer()
                                Text("₺\(item.amount, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Son 7 günlük harcama trendi
                VStack(alignment: .leading, spacing: 12) {
                    Text("Son 7 Gün")
                        .font(.headline)
                    
                    Chart(last7DaysData, id: \.date) { item in
                        LineMark(
                            x: .value("Gün", item.date, unit: .day),
                            y: .value("Gider", item.amount)
                        )
                        .foregroundStyle(.red)
                        
                        AreaMark(
                            x: .value("Gün", item.date, unit: .day),
                            y: .value("Gider", item.amount)
                        )
                        .foregroundStyle(.red.opacity(0.1))
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.06), radius: 6)
                }
            }
            .padding()
        }
        .navigationTitle("Grafikler")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // Son 7 günlük veri
    var last7DaysData: [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        return (0..<7).reversed().map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let amount = viewModel.transactions
                .filter {
                    $0.type == .expense &&
                    calendar.isDate($0.date, inSameDayAs: date)
                }
                .reduce(0) { $0 + $1.amount }
            return (date, amount)
        }
    }
}

#Preview {
    NavigationStack {
        ChartsView(viewModel: BudgetViewModel())
    }
}
