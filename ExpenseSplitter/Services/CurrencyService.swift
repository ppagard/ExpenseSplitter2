// Services/CurrencyService.swift
import Foundation
import Combine

class CurrencyService: ObservableObject {
    @Published var currencies: [Currency] = Currency.defaultCurrencies
    @Published var lastUpdated: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSavedData()
        fetchExchangeRates()
    }
    
    func fetchExchangeRates() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://api.frankfurter.app/latest?from=SEK") else {
            errorMessage = "Ogiltig webb-adress"
            isLoading = false
            return
        }
        
        URLSession.shared.dataPublisher(for: url)
            .map(\.data)
            .decode(type: FrankfurterResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.handleNetworkError(error)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.updateCurrenciesFromResponse(response)
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleNetworkError(_ error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = "Ingen internetanslutning tillgänglig"
            case .timedOut:
                errorMessage = "Anslutningen tog för lång tid"
            case .cannotFindHost:
                errorMessage = "Kan inte hitta valutaservern"
            case .networkConnectionLost:
                errorMessage = "Nätverksanslutningen förlorades"
            default:
                errorMessage = "Nätverksfel: Kunde inte hämta valutakurser"
            }
        } else if error is DecodingError {
            errorMessage = "Fel vid tolkning av valutadata"
        } else {
            errorMessage = "Okänt fel vid hämtning av valutakurser"
        }
        print("Valutafel: \(error.localizedDescription)")
    }
    
    private func updateCurrenciesFromResponse(_ response: FrankfurterResponse) {
        var updatedCurrencies: [Currency] = []
        
        updatedCurrencies.append(Currency(id: "SEK", name: "Svenska kronor", symbol: "kr", rate: 1.0))
        
        for (code, rate) in response.rates {
            let name = getCurrencyName(for: code)
            let symbol = getCurrencySymbol(for: code)
            updatedCurrencies.append(Currency(id: code, name: name, symbol: symbol, rate: rate))
        }
        
        self.currencies = updatedCurrencies.sorted { $0.name < $1.name }
        self.lastUpdated = Date()
        saveCurrencies()
        errorMessage = nil
    }
    
    private func getCurrencyName(for code: String) -> String {
        let currencyNames: [String: String] = [
            "USD": "US Dollar", "EUR": "Euro", "GBP": "Brittiska pund",
            "NOK": "Norska kronor", "DKK": "Danska kronor", "CHF": "Schweizerfranc",
            "JPY": "Japanska yen", "CAD": "Kanadensiska dollar", "AUD": "Australienska dollar",
            "CNY": "Kinesiska yuan", "INR": "Indiska rupier", "BRL": "Brasilianska real",
            "RUB": "Ryska rubel", "KRW": "Sydkoreanska won", "SGD": "Singaporeansk dollar",
            "HKD": "Hongkong dollar", "MXN": "Mexikanska peso", "THB": "Thailändska baht",
            "TRY": "Turkiska lira", "ZAR": "Sydafrikanska rand", "PLN": "Polska zloty",
            "CZK": "Tjeckiska kronor", "HUF": "Ungerska forint", "RON": "Rumänska leu",
            "BGN": "Bulgariska lev", "HRK": "Kroatiska kuna", "ISK": "Isländska kronor"
        ]
        return currencyNames[code] ?? code
    }
    
    private func getCurrencySymbol(for code: String) -> String {
        let currencySymbols: [String: String] = [
            "USD": "$", "EUR": "€", "GBP": "£", "NOK": "kr", "DKK": "kr",
            "CHF": "CHF", "JPY": "¥", "CAD": "C$", "AUD": "A$", "CNY": "¥",
            "INR": "₹", "BRL": "R$", "RUB": "₽", "KRW": "₩", "SGD": "S$",
            "HKD": "HK$", "MXN": "$", "THB": "฿", "TRY": "₺", "ZAR": "R",
            "PLN": "zł", "CZK": "Kč", "HUF": "Ft", "RON": "lei", "BGN": "лв",
            "HRK": "kn", "ISK": "kr"
        ]
        return currencySymbols[code] ?? code
    }
    
    private func saveCurrencies() {
        if let encoded = try? JSONEncoder().encode(currencies) {
            UserDefaults.standard.set(encoded, forKey: "currencies")
        }
        UserDefaults.standard.set(lastUpdated, forKey: "lastUpdated")
    }
    
    private func loadSavedData() {
        if let data = UserDefaults.standard.data(forKey: "currencies"),
           let decoded = try? JSONDecoder().decode([Currency].self, from: data) {
            currencies = decoded
        }
        lastUpdated = UserDefaults.standard.object(forKey: "lastUpdated") as? Date
    }
}

struct FrankfurterResponse: Codable {
    let amount: Double
    let base: String
    let date: String
    let rates: [String: Double]
}
