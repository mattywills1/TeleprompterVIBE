import Foundation

struct DisplayLine: Identifiable, Hashable {
    let id: Int
    let words: [DisplayWord]
    
    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DisplayLine, rhs: DisplayLine) -> Bool {
        lhs.id == rhs.id
    }
}

struct DisplayWord: Identifiable, Hashable {
    let id = UUID()
    let text: String
    var isCurrent: Bool = false
    var isSpoken: Bool = false
    
    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DisplayWord, rhs: DisplayWord) -> Bool {
        lhs.id == rhs.id
    }
}