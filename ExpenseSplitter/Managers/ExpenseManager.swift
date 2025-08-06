import Foundation

class ExpenseManager: ObservableObject {
    @Published var expenseGroups: [ExpenseGroup] = []
    @Published var selectedGroup: ExpenseGroup?
    
    init() {
        loadData()
    }
    
    func createGroup(name: String, baseCurrency: Currency) {
        let group = ExpenseGroup(name: name, baseCurrency: baseCurrency)
        expenseGroups.append(group)
        selectedGroup = group
        saveData()
    }
    
    func deleteGroup(_ group: ExpenseGroup) {
        expenseGroups.removeAll { $0.id == group.id }
        if selectedGroup?.id == group.id {
            selectedGroup = expenseGroups.first
        }
        saveData()
    }
    
    func addPersonToGroup(_ person: Person, group: ExpenseGroup) {
        guard let index = expenseGroups.firstIndex(where: { $0.id == group.id }) else { return }
        expenseGroups[index].participants.append(person)
        if selectedGroup?.id == group.id {
            selectedGroup = expenseGroups[index]
        }
        saveData()
    }
    
    func removePersonFromGroup(_ person: Person, group: ExpenseGroup) {
        guard let index = expenseGroups.firstIndex(where: { $0.id == group.id }) else { return }
        expenseGroups[index].participants.removeAll { $0.id == person.id }
        if selectedGroup?.id == group.id {
            selectedGroup = expenseGroups[index]
        }
        saveData()
    }
    
    func addExpenseToGroup(_ expense: Expense, group: ExpenseGroup) {
        guard let index = expenseGroups.firstIndex(where: { $0.id == group.id }) else { return }
        expenseGroups[index].expenses.append(expense)
        if selectedGroup?.id == group.id {
            selectedGroup = expenseGroups[index]
        }
        saveData()
    }
    
    func calculateDebtsForGroup(_ group: ExpenseGroup) -> [Debt] {
        var balances: [UUID: Double] = [:]
        
        for person in group.participants {
            balances[person.id] = 0.0
        }
        
        for expense in group.expenses {
            let amountInBaseCurrency = expense.amountInBaseCurrency(group.baseCurrency)
            let amountPerPerson = amountInBaseCurrency / Double(expense.splitBetween.count)
            
            balances[expense.paidBy.id, default: 0.0] += amountInBaseCurrency
            
            for person in expense.splitBetween {
                balances[person.id, default: 0.0] -= amountPerPerson
            }
        }
        
        var debts: [Debt] = []
        let sortedBalances = balances.sorted { $0.value < $1.value }
        
        var creditors = sortedBalances.filter { $0.value > 0.01 }
        var debtors = sortedBalances.filter { $0.value < -0.01 }
        
        for debtor in debtors {
            var remainingDebt = abs(debtor.value)
            
            for i in 0..<creditors.count {
                if remainingDebt <= 0.01 { break }
                if creditors[i].value <= 0.01 { continue }
                
                let paymentAmount = min(remainingDebt, creditors[i].value)
                
                if let debtorPerson = group.participants.first(where: { $0.id == debtor.key }),
                   let creditorPerson = group.participants.first(where: { $0.id == creditors[i].key }) {
                    debts.append(Debt(debtor: debtorPerson, creditor: creditorPerson, amount: paymentAmount, currency: group.baseCurrency))
                }
                
                creditors[i] = (creditors[i].key, creditors[i].value - paymentAmount)
                remainingDebt -= paymentAmount
            }
        }
        
        return debts.filter { $0.amount > 0.01 }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(expenseGroups) {
            UserDefaults.standard.set(encoded, forKey: "expenseGroups")
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "expenseGroups"),
           let decoded = try? JSONDecoder().decode([ExpenseGroup].self, from: data) {
            expenseGroups = decoded
            selectedGroup = expenseGroups.first
        }
    }
}
