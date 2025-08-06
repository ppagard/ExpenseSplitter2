import Foundation

struct Currency: Identifiable, Codable {
    let id: String // ISO kod som "SEK", "USD", "EUR"
    let name: String
    let symbol: String
    var rate: Double // Växelkurs mot basvalutan
    
    static let defaultCurrencies = [
        Currency(id: "SEK", name: "Svenska kronor", symbol: "kr", rate: 1.0),
        Currency(id: "USD", name: "US Dollar", symbol: "$", rate: 0.092),
        Currency(id: "EUR", name: "Euro", symbol: "€", rate: 0.087),
        Currency(id: "NOK", name: "Norska kronor", symbol: "kr", rate: 1.02),
        Currency(id: "DKK", name: "Danska kronor", symbol: "kr", rate: 0.65)
    ]
}
