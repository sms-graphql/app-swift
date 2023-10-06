import SwiftUI
import Apollo
import MovieYourself

struct MovieView: View {
    
    @ObservedObject var movieData = MoviesData()
    
    @State private var searchText = ""
    
    
    @State private var isSheetPresented = false
    @State private var movieSelected: AllMoviesQuery.Data.Movie?
    
    var body: some View {
        NavigationView {
            VStack {
                if movieData.movies.isEmpty{
                    ProgressView().onAppear{
                        movieData.fetchMovies()
                    }
                } else {
                    List(movieData.movies, id: \.__data){ movie in
                        if let title = movie.title {
                            if searchText == ""{
                                Text(title).onTapGesture {
                                    movieSelected = movie
                                    isSheetPresented = true
                                }
                            } else if title.contains(searchText){
                                Text(title).onTapGesture {
                                    movieSelected = movie
                                    isSheetPresented = true
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText)
                    .refreshable {
                        movieData.fetchMovies()
                    }
                }
            }.navigationTitle("Films à l'affiche").toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: ContentView(), label: {
                        Image(systemName: "power")
                    }).onTapGesture {
                        logout()
                    }
                }
            }.navigationBarBackButtonHidden(true)
                .sheet(isPresented: Binding(
                    get: { movieSelected != nil },
                    set: { isSheetPresented = $0 }
                )) {
                    if let movie = movieSelected {
                        AddMovieToPlaylistView( movie: movie).onDisappear {
                            movieSelected = nil
                        }
                    }
                }
        }
    }
    func logout(){
        Network.shared.apollo.fetch(query: LogoutQuery(),cachePolicy: .fetchIgnoringCacheData){  result in

            switch result {
            case .success(let graphQLResult):
                if graphQLResult.errors != nil {
                }
                else{
                    
                }
            case .failure(let error):
                print("Failure! Error: \(error)")
            }
        }
    }
}

#Preview {
    MovieView()
}

class MoviesData: ObservableObject {
    @Published var movies: [AllMoviesQuery.Data.Movie] = []
    
    func fetchMovies() {
        Network.shared.apollo.fetch(query: AllMoviesQuery(),cachePolicy: .fetchIgnoringCacheData){ [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let graphQLResult):
                if let movies = graphQLResult.data?.movies {
                    self.movies.removeAll()
                    self.movies.append(contentsOf: movies.compactMap({$0}))
                }
            case .failure(let error):
                print("Failure! Error: \(error)")
            }
        }
    }
}
