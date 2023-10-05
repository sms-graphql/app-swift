import Foundation

class Actor:Identifiable{
    
    var firstname: String
    var lastname: String
    var dateOfBirth: String
    
    init(firstname: String, lastname: String, dateOfBirth: String) {
        self.firstname = firstname
        self.lastname = lastname
        self.dateOfBirth = dateOfBirth
    }
}
