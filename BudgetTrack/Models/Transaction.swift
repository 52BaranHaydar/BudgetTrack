//
//  Transaction.swift
//  BudgetTrack
//
//  Created by Baran on 19.03.2026.
//

import Foundation

struct Transaction: Identifiable, Codable{
    
    let id : String
    var title : String
    var amount : Double
    var date : Date
    var category : Category
    var type :TransactionType
    var location : String?
    
    enum TransactionType: String, Codable, CaseIterable{
        case income  = "Gelir"
        case expense = "Gider"
    }
    
    enum Category :String, Codable, CaseIterable{
        case food = "Yemek"
        case transport = "Ulaşım"
        case shopping = "Alışeriş"
        case bills = "Faturalar"
        case entertainment = "Eğlence"
        case health = "Sağlık"
        case education = "Eğitim"
        case salary = "Maaş"
        case other = "Diğer"
        
        var icon :String {
            switch self {
            case .food: return "fork.knife"
            case .transport: return "car.fill"
            case .shopping: return "bag.fill"
            case .bills: return "doc.fill"
            case .entertainment: return "gamecontroller.fill"
            case .health: return "heart.fill"
            case .education: return "book.fill"
            case .salary: return "banknote.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
        
        var color :String {
            switch self{
            case . food: return "orange"
            case . transport: return "blue"
            case .shopping: return "purple"
            case .bills: return "red"
            case .entertainment: return "pink"
            case .health: return "green"
            case .education: return "teal"
            case .salary: return "green"
            case .other: return "gray"
            }
        }
    }
    
    init(
        id: String = UUID().uuidString,
        title : String,
        amount:Double,
        date : Date = Date(),
        category: Category,
        type: TransactionType,
        location:String? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.type = type
        self.location = location
    }
    
}
