import Foundation

struct ExpenseGroup: Identifiable, Codable {
    var id = UUID()
    var name: String
    var baseCurrency: Currency
    var participants: [Person]
    var expenses: [Expense]
    var createdDate: Date
    
    init(name: String, baseCurrency: Currency) {
        self.name = name
        self.baseCurrency = baseCurrency
        self.participants = []
        self.expenses = []
        self.createdDate = Date()
    }
}
