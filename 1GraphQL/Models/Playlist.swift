import Foundation

class Playlist: Identifiable{
    
    var name: String
    var movies: [Movie]
    
    init(name: String, movies: [Movie]) {
        self.name = name
        self.movies = movies
    }
}
