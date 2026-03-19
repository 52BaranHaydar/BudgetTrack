//
//  FirebaseService.swift
//  BudgetTrack
//
//  Created by Baran on 19.03.2026.
//

import Foundation
import FirebaseFirestore
import Combine

class FirebaseService: ObservableObject {
    
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let collectionName = "transactions"
    
    // İşlem ekle
    func addTransaction(_ transaction: Transaction) async throws {
        let data: [String: Any] = [
            "id": transaction.id,
            "title": transaction.title,
            "amount": transaction.amount,
            "date": Timestamp(date: transaction.date),
            "category": transaction.category.rawValue,
            "type": transaction.type.rawValue,
            "location": transaction.location ?? ""
        ]
        try await db.collection(collectionName).document(transaction.id).setData(data)
    }
    
    // Tüm işlemleri getir
    func fetchTransactions() async throws -> [Transaction] {
        let snapshot = try await db.collection(collectionName)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let id = data["id"] as? String,
                  let title = data["title"] as? String,
                  let amount = data["amount"] as? Double,
                  let timestamp = data["date"] as? Timestamp,
                  let categoryString = data["category"] as? String,
                  let category = Transaction.Category(rawValue: categoryString),
                  let typeString = data["type"] as? String,
                  let type = Transaction.TransactionType(rawValue: typeString) else { return nil }
            
            return Transaction(
                id: id,
                title: title,
                amount: amount,
                date: timestamp.dateValue(),
                category: category,
                type: type,
                location: data["location"] as? String
            )
        }
    }
    
    // İşlem sil
    func deleteTransaction(_ transaction: Transaction) async throws {
        try await db.collection(collectionName).document(transaction.id).delete()
    }
}
