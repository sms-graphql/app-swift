import SwiftUI
import Apollo
import MovieYourself

struct AddMovieToPlaylistView: View {

    @State private var selectedOption = 0
    @State var playlists: [GetUserPlaylistsQuery.Data.UserPlaylist] = []
    @State private var isAlreadyInPlaylist: Bool = false
    @State private var isMovieAdded = false
    @State private var showAlert = false
    @State private var alertMessage = ""
        
    @State var options: [String] = []
    @State var movie: AllMoviesQuery.Data.Movie?
    @State var movieDetail: GetMovieByIdQuery.Data.Movie?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8){
                Text(movieDetail?.title ?? "Pas de titre")
                    .font(Font.system(size: 36))
                    .bold()
                HStack {
                    Text("Categorie: ")
                        .font(Font.system(size: 18)).bold()
                    Text(movieDetail?.category?.name ?? "")
                        .font(Font.system(size: 18))
                    Spacer()
                }
                HStack {
                    Text("Studio: ")
                        .font(Font.system(size: 18)).bold()
                    Text(movieDetail?.studio?.name ?? "")
                        .font(Font.system(size: 18))
                    Spacer()
                }
                HStack{
                    Text("Pays:")
                        .font(Font.system(size: 18)).bold()
                    Text(movieDetail?.studio?.country ?? "")
                        .font(Font.system(size: 18))
                }
                HStack{
                    Text("Réalisateur:")
                        .font(Font.system(size: 18)).bold()
                }
                VStack{
                    if let directors = movieDetail?.directors{
                        ForEach(directors,id: \.?.__data){ director in
                            HStack {
                                Text("\(director?.last_name ?? "") \(director?.first_name ?? "")").font(Font.system(size: 18))
                                Spacer()
                            }
                        }
                    }
                }
                
                HStack{
                    Text("Acteur:").font(Font.system(size: 18)).bold()
                }
                VStack{
                    if let actors = movieDetail?.actors{
                        ForEach(actors,id: \.?.__data){ actor in
                            HStack {
                                Text("\(actor?.last_name ?? "") \(actor?.first_name ?? "")").font(Font.system(size: 18))
                                Spacer()
                            }
                            
                        }
                    }
                }
                HStack {
                    if !isAlreadyInPlaylist || options.count > 0{
                        Picker("Sélectionner une playlist",
                               selection: $selectedOption){
                            ForEach(0..<options.count,id: \.self){ index in
                                Text(options[index])
                            }
                        }.pickerStyle(.menu)
                    }
                    NavigationLink {
                        if isAlreadyInPlaylist{
                            PlaylistView()
                        } else {
                           MovieView()
                        }
                    } label: {
                        Button(action: {
                            if isAlreadyInPlaylist || options.count == 0{
                                
                            }else{
                                AddMovieToPlaylist()
                            }
                        }, label: {
                            if isAlreadyInPlaylist || options.count == 0{
                            }else {
                                Text("Ajouter le film à la playlist").foregroundStyle(.blue)
                            }
                        })
                    }
                }
            }.padding()
        }.onAppear{
            fetchMovieDetails()
            fetchPlaylistUser()
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text(isMovieAdded ? "Succès" : "Erreur"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    isAlreadyInPlaylist = !isAlreadyInPlaylist
                }
            )
        }
            
    }
    
    func AddMovieToPlaylist(){
        guard let movieId = movie?.id else {
            return
        }
        guard let playlistID = playlists[selectedOption].id else {
            return
        }
        Network.shared.apollo.perform(mutation: AddMovieToPlaylistMutation(playlistId: playlistID, movieId: "\(movieId)")){
            result in
            switch result{
            case .success(let graphQLResult):
                if graphQLResult.errors != nil {
                    isMovieAdded = false
                    alertMessage = "Erreur le film n'a pas pu etre ajouté a la playlist ❌"
                } else {
                    isMovieAdded = true
                    alertMessage = "Le film a été ajouté a la playlist 🎬"
                }
                showAlert = true
                
            case .failure(_):
                print("Erreur")
            }
        }
    }
    
    func fetchMovieDetails(){
        guard let movieId = movie?.id else {
            return
        }
        Network.shared.apollo.fetch(query: GetMovieByIdQuery(id: movieId),cachePolicy: .fetchIgnoringCacheData){  result in
            switch result {
            case .success(let graphQLResult):
                if graphQLResult.errors != nil {
                    
                }
                else {
                    if let currentMovie = graphQLResult.data?.movie{
                        self.movieDetail = currentMovie
                    }
                }
            case .failure(_):
                print("Failure! Error")
            }
        }
    }
    
    func fetchPlaylistUser(){
        Network.shared.apollo.fetch(query: GetUserPlaylistsQuery(), cachePolicy: CachePolicy.fetchIgnoringCacheData) {  result in
            switch result {
            case .success(let graphQLResult):
                print(graphQLResult.data?.userPlaylists)
                if let newplaylists = graphQLResult.data?.userPlaylists {
                    print("oldPlaylist: \(playlists.count)")
                    print("newPlaylist: \(newplaylists.count)")
                    self.playlists.removeAll()
                    self.playlists.append(contentsOf: newplaylists.compactMap({$0}))
                    self.options.removeAll()
                    self.options = playlists.map({ playlist in
                        playlist.name ?? ""
                    })
                    
                }
            case .failure(_):
                print("Failure! Error")
            }
        }
    }
}

#Preview {
    AddMovieToPlaylistView(movie: nil)
}
