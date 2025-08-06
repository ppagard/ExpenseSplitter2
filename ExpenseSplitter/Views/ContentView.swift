import SwiftUI

struct ContentView: View {
    @StateObject private var expenseManager = ExpenseManager()
    @StateObject private var currencyService = CurrencyService()
    
    var body: some View {
        TabView {
            NavigationView {
                GroupsView(expenseManager: expenseManager, currencyService: currencyService)
            }
            .tabItem {
                Image(systemName: "folder")
                Text("Grupper")
            }
            
            NavigationView {
                if let selectedGroup = expenseManager.selectedGroup {
                    ExpensesView(group: selectedGroup, expenseManager: expenseManager, currencyService: currencyService)
                } else {
                    VStack {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Skapa en grupp först")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .tabItem {
                Image(systemName: "receipt")
                Text("Utgifter")
            }
            
            NavigationView {
                if let selectedGroup = expenseManager.selectedGroup {
                    DebtsView(group: selectedGroup, expenseManager: expenseManager)
                } else {
                    VStack {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Välj en grupp först")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .tabItem {
                Image(systemName: "dollarsign.circle")
                Text("Skulder")
            }
            
            NavigationView {
                if let selectedGroup = expenseManager.selectedGroup {
                    PeopleView(group: selectedGroup, expenseManager: expenseManager)
                } else {
                    VStack {
                        Image(systemName: "person.3")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Välj en grupp först")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .tabItem {
                Image(systemName: "person.3")
                Text("Deltagare")
            }
            
            NavigationView {
                CurrenciesView(currencyService: currencyService)
            }
            .tabItem {
                Image(systemName: "coloncurrencysign.circle")
                Text("Valutor")
            }
        }
    }
}
