import SwiftUI
import Apollo
import MovieYourself

struct MoviesPlaylistView: View {
    
    @State var playlistID: ID
    @State var movies: [GetMoviesPlaylistQuery.Data.Playlist.Movie] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView{
            VStack{
                List{
                    ForEach(movies,id: \.__data){ movie in
                        NavigationLink(destination: MovieDetail(movieP: movie)) {
                            Text(movie.title ?? "Pas de titre")
                                .font(.system(size: 24))
                                .padding()
                        }
                    }.onDelete(perform: deleteMovieFromPlaylist)
                }.refreshable {
                    fetchMovies()
                }
            }
        }.onAppear{
            fetchMovies()
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text("Films"),
                message: Text(alertMessage)
            )
        }
    }
    
    func deleteMovieFromPlaylist(at offsets: IndexSet){
        guard let index = offsets.first else {
            return
        }
        
        guard let movieId = movies[index].id else {
            return
        }
        
        Network.shared.apollo.perform(mutation: RemoveMovieFromPlaylistMutation(playlistId: playlistID, movieId: "\(movieId)")){
            result in
            switch result{
            case .success(let graphQLResult):
                if graphQLResult.errors != nil {
                    alertMessage = "Erreur "
                } else {
                    alertMessage = "La film a bien été supprimé "
                    movies.remove(atOffsets: offsets)
                }
                showAlert = true
            case .failure(_):
                print("Erreur")
            }
            
        }
    }
    
    func fetchMovies(){
        guard let playlistId = Int(playlistID) else {
            return
        }
        Network.shared.apollo.fetch(query: GetMoviesPlaylistQuery(id: playlistId ),cachePolicy: .fetchIgnoringCacheData){  result in
            switch result {
            case .success(let graphQLResult):
                if let movies = graphQLResult.data?.playlist?.movies {
                    self.movies.removeAll()
                    self.movies.append(contentsOf: movies.compactMap({$0}))
                }
            case .failure(let error):
                print("Failure! Error: \(error)")
            }
        }
    }
}

#Preview {
    MoviesPlaylistView(playlistID: "1")
}
