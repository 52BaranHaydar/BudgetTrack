//
//  BudgetViewModel.swift
//  BudgetTrack
//
//  Created by Baran on 19.03.2026.
//

import Foundation
import Combine

class BudgetViewModel: ObservableObject{
    
    @Published var transactions : [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage : String?
    
    private let firebaseService = FirebaseService.shared
    
    // Toplam gelir
    var totalIncome:Double {
        
        transactions.filter{
            $0.type == .income}
        .reduce(0){
            $0 + $1.amount}
    }
    // Toplam gider
    var totalExpense: Double{
        transactions
            .filter{ $0.type == .expense}
            .reduce(0){ $0 + $1.amount }
    }
    // Kategoriye göre harcama
    func expenses(for category: Transaction.Category) -> Double {
        transactions
            .filter{$0.type == .expense && $0.category == category}
            .reduce(0){ $0 + $1.amount}
    }
    // Bakiye
    var balance :Double{
        totalIncome - totalExpense
    }
    // Son işlemler
    var recentTransactions : [Transaction]{
        Array(transactions.prefix(10))
    }
    
    func fetchTransactions() async {
        await MainActor.run {isLoading = true}
        
        do {
            let fetched = try await firebaseService.fetchTransactions()
            await MainActor.run{
                self.transactions = fetched
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
        
    }
    // İşlem Ekle
    func addTransaction(_ transaction: Transaction) async {
            do {
                try await firebaseService.addTransaction(transaction)
                await fetchTransactions()
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    // işlem Sil
    func deleteTransaction(_ transaction :Transaction) async {
        do{
            try await firebaseService.deleteTransaction(transaction)
            await MainActor.run{
                self.transactions.removeAll{
                    $0.id == transaction.id}
                
            }
        } catch {
            await MainActor.run{
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // Kategoriye göre grupla
    var expensesByCategory: [(category: Transaction.Category, amount :Double)] {
        Transaction.Category.allCases.compactMap{ category in
            let amount = expenses(for: category)
            return amount > 0 ? (category, amount) : nil
        }
        .sorted{ $0.amount > $1.amount}
    }
    
    
    
    
    
    
}
