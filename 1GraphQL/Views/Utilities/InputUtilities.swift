import Foundation

class InputUtilities{
    
    static func isUserOver18(dateOfBirth: Date) -> Bool {
        let calendar = Calendar.current
        let current = Date()
        if let date = calendar.date(byAdding: .year, value: -18, to: current) {
            return dateOfBirth <= date
        }
        return false
    }
}
