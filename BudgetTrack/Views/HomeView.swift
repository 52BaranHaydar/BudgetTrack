//
//  HomeView.swift
//  BudgetTrack
//
//  Created by Baran on 19.03.2026.
//
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @State private var showAddTransaction = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Ana Sayfa
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        BalanceCard(viewModel: viewModel)
                        
                        HStack(spacing: 16) {
                            SummaryCard(
                                title: "Gelir",
                                amount: viewModel.totalIncome,
                                color: .green,
                                icon: "arrow.down.circle.fill"
                            )
                            SummaryCard(
                                title: "Gider",
                                amount: viewModel.totalExpense,
                                color: .red,
                                icon: "arrow.up.circle.fill"
                            )
                        }
                        
                        if !viewModel.transactions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Son İşlemler")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(viewModel.recentTransactions) { transaction in
                                    TransactionRow(transaction: transaction) {
                                        Task {
                                            await viewModel.deleteTransaction(transaction)
                                        }
                                    }
                                }
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "creditcard")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.secondary)
                                Text("Henüz işlem yok")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 40)
                        }
                    }
                    .padding()
                }
                .navigationTitle("BudgetTrack")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAddTransaction = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .sheet(isPresented: $showAddTransaction) {
                    AddTransactionView(viewModel: viewModel)
                }
                .task {
                    await viewModel.fetchTransactions()
                }
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house.fill")
            }
            .tag(0)
            
            // Grafikler
            NavigationStack {
                ChartsView(viewModel: viewModel)
            }
            .tabItem {
                Label("Grafikler", systemImage: "chart.pie.fill")
            }
            .tag(1)
            
            NavigationStack {
                MapView(viewModel: viewModel)
                }
                .tabItem {
                    Label("Harita", systemImage: "map.fill")
                }
                .tag(2)
        }
    }
}

// Bakiye kartı
struct BalanceCard: View {
    @ObservedObject var viewModel: BudgetViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Toplam Bakiye")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            
            Text("₺\(viewModel.balance, specifier: "%.2f")")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// Özet kartı
struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("₺\(amount, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundStyle(color)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 6)
    }
}

// İşlem satırı
struct TransactionRow: View {
    let transaction: Transaction
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.category.icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(transaction.type == .income ? Color.green : Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(transaction.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.type == .income ? "+" : "-")₺\(transaction.amount, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(transaction.type == .income ? .green : .red)
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 6)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }
}

#Preview {
    HomeView()
}
