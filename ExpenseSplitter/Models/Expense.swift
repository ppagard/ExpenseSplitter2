import Foundation

struct Expense: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var currency: Currency
    var paidBy: Person
    var splitBetween: [Person]
    var date: Date
    
    init(title: String, amount: Double, currency: Currency, paidBy: Person, splitBetween: [Person]) {
        self.title = title
        self.amount = amount
        self.currency = currency
        self.paidBy = paidBy
        self.splitBetween = splitBetween
        self.date = Date()
    }
    
    func amountInBaseCurrency(_ baseCurrency: Currency) -> Double {
        if currency.id == baseCurrency.id {
            return amount
        }
        // Konvertera till basvaluta
        return amount * (baseCurrency.rate / currency.rate)
    }
    
    func amountPerPersonInBaseCurrency(_ baseCurrency: Currency) -> Double {
        return amountInBaseCurrency(baseCurrency) / Double(splitBetween.count)
    }
}
