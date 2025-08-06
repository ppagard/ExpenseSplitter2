import SwiftUI

struct AddGroupView: View {
    @ObservedObject var expenseManager: ExpenseManager
    @ObservedObject var currencyService: CurrencyService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var groupName = ""
    @State private var selectedCurrency: Currency?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gruppinformation")) {
                    TextField("Gruppnamn", text: $groupName)
                }
                
                Section(header: Text("Basvaluta")) {
                    Picker("Valuta", selection: $selectedCurrency) {
                        Text("Välj valuta").tag(nil as Currency?)
                        ForEach(currencyService.currencies) { currency in
                            Text("\(currency.name) (\(currency.symbol))").tag(currency as Currency?)
                        }
                    }
                }
                
                Section(footer: Text("Basvalutan används för skuldberäkningar. Alla utgifter konverteras till denna valuta.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Ny Grupp")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Avbryt") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skapa") {
                        createGroup()
                    }
                    .disabled(groupName.isEmpty || selectedCurrency == nil)
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Fel"), message: Text(alertMessage), dismissButton: .default(Text("Stäng")))
        }
    }
    
    func createGroup() {
        guard !groupName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Ange ett giltigt gruppnamn"
            showingAlert = true
            return
        }
        
        guard let currency = selectedCurrency else {
            alertMessage = "Välj en basvaluta för gruppen"
            showingAlert = true
            return
        }
        
        // Kontrollera om gruppnamnet redan finns
        if expenseManager.expenseGroups.contains(where: { $0.name.lowercased() == groupName.lowercased() }) {
            alertMessage = "En grupp med detta namn finns redan"
            showingAlert = true
            return
        }
        
        expenseManager.createGroup(name: groupName.trimmingCharacters(in: .whitespaces), baseCurrency: currency)
        presentationMode.wrappedValue.dismiss()
    }
}
