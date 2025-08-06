import SwiftUI

struct GroupsView: View {
    @ObservedObject var expenseManager: ExpenseManager
    @ObservedObject var currencyService: CurrencyService
    @State private var showingAddGroup = false
    
    var body: some View {
        VStack {
            List {
                ForEach(expenseManager.expenseGroups) { group in
                    GroupRowView(group: group, isSelected: expenseManager.selectedGroup?.id == group.id)
                        .onTapGesture {
                            expenseManager.selectedGroup = group
                        }
                }
                .onDelete(perform: deleteGroups)
            }
            
            if expenseManager.expenseGroups.isEmpty {
                VStack {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Inga grupper skapade")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Tryck på + för att skapa en grupp")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Utgiftsgrupper")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddGroup = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddGroup) {
            AddGroupView(expenseManager: expenseManager, currencyService: currencyService)
        }
    }
    
    func deleteGroups(offsets: IndexSet) {
        for index in offsets {
            expenseManager.deleteGroup(expenseManager.expenseGroups[index])
        }
    }
}

struct GroupRowView: View {
    let group: ExpenseGroup
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(group.name)
                        .font(.headline)
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                Text("\(group.participants.count) deltagare • \(group.expenses.count) utgifter")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Basvaluta: \(group.baseCurrency.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}
