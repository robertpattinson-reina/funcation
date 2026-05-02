import Foundation

struct PriceParser {
    static func parsePrice(_ text: String) -> Double {
        let cleaned = text
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return Double(cleaned) ?? 0
    }
}
