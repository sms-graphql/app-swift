import Foundation

class Movie: Identifiable {
    
    var title: String
    var category: Category
    var studio: Studio
    
    init(title: String, category: Category, studio: Studio) {
        self.title = title
        self.category = category
        self.studio = studio
    }
}

