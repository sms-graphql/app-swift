import SwiftUI
import Apollo
import MovieYourself


struct MovieDetail: View {
    
    let movieP: GetMoviesPlaylistQuery.Data.Playlist.Movie?
    @State var movie: GetMovieByIdQuery.Data.Movie? = nil
    
    var body: some View {
        VStack(alignment: .leading,spacing: 20){
            Text(movie?.title ?? "Pas de titre").font(.title)
            HStack{
                Text("Studio:").bold()
                Text(movie?.studio?.name ?? "")
                Spacer()
            }
            HStack{
                Text("Pays:").bold()
                Text(movie?.studio?.country ?? "")
            }
            HStack{
                Text("Réalisateur:").bold()
            }
            VStack{
                if let directors = movie?.directors{
                    ForEach(directors,id: \.?.__data){ director in
                        HStack {
                            Text("\(director?.last_name ?? "") \(director?.first_name ?? "")")
                            Spacer()
                        }
                    }
                }
            }
            HStack{
                Text("Acteur:").bold()
            }
            VStack{
                if let actors = movie?.actors{
                    ForEach(actors,id: \.?.__data){ actor in
                        HStack {
                            Text("\(actor?.last_name ?? "") \(actor?.first_name ?? "")")
                            Spacer()
                        }
                    }
                }
            }
            Spacer()
        }.padding().onAppear{
            fetchInfoMovie()
        }
    }
    
    func fetchInfoMovie(){
        guard let movieId = movieP?.id else{
            return
        }
        Network.shared.apollo.fetch(query: GetMovieByIdQuery(id: movieId),cachePolicy: .fetchIgnoringCacheData){  result in
            switch result {
            case .success(let graphQLResult):
                if let movie1 = graphQLResult.data?.movie {
                    self.movie = movie1
                }
            case .failure(let error):
                print("Failure! Error: \(error)")
            }
        }
    }
}

#Preview {
    MovieDetail(movieP: nil)
}
