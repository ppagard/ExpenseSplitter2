import Foundation

struct Person: Identifiable, Codable {
    var id = UUID()
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
