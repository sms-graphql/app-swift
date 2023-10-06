import SwiftUI
import Apollo
import MovieYourself

struct PlaylistView: View {
    
    @State var playlists: [GetUserPlaylistsQuery.Data.UserPlaylist] = []
    
    @State private var isSheetPresented = false
    
    @State private var loadData = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isEditing = false
    @State private var showEditing = false
    @State private var newName = ""
    @State private var selectedPlaylist = ""
    
    var body: some View {
        
        NavigationView {
            VStack{
                if playlists.isEmpty && !loadData{
                    ProgressView().onAppear{
                        self.loadData = true
                        fetchPlaylists()
                    }
                }else if playlists.isEmpty && loadData{
                    Text("Pas de playlist").refreshable {
                        fetchPlaylists()
                    }
                }
                else{
                    List {
                        ForEach(playlists, id: \.__data) { playlist in
                            if isEditing{
                                if showEditing && playlist.id == selectedPlaylist{
                                    TextField("",text: $newName)
                                }else{
                                    Text(playlist.name ?? "Playlist sans titre ")
                                        .font(.system(size: 24))
                                        .onTapGesture {
                                            if !showEditing{
                                                showEditing = true
                                                newName = playlist.name ?? ""
                                                selectedPlaylist = playlist.id ?? ""
                                            }
                                        }
                                }
                            }else{
                                NavigationLink(destination: MoviesPlaylistView(playlistID: playlist.id ?? "")) {
                                    HStack {
                                        Text(playlist.name ?? "Playlist sans titre ")
                                            .font(.system(size: 24))
                                        Spacer()
                                        Text("\(playlist.movies?.count ?? 0) films")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deletePlaylist)
                    }
                    .refreshable {
                        fetchPlaylists()
                    }
                }
            }.navigationTitle("Mes playlists")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            if isEditing{
                                saveNewName()
                                showEditing = true
                            }else {
                                showEditing = false
                            }
                            
                            isEditing = !isEditing
                        }, label: {
                            HStack{
                                Text(isEditing ? "Save" : "Edit")
                            }
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            isSheetPresented = true
                        }, label: {
                            HStack{
                                Image(systemName: "plus")
                                Text("add playlist")
                            }
                        })
                    }
                }
        }.onAppear{
            fetchPlaylists()
        }
        .sheet(isPresented: $isSheetPresented, content: {
            CreatePlaylistView(isSheetPresented: $isSheetPresented)
                .presentationDetents([.height(150)]).onDisappear{
                    fetchPlaylists()
                }
        }).alert(isPresented: $showAlert) {
            Alert(
                title: Text("Playlist"),
                message: Text(alertMessage)
            )
        }
    }
    
    func saveNewName(){
        if selectedPlaylist.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
            newName.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            Network.shared.apollo.perform(mutation: UpdatePlaylistNameMutation(id: selectedPlaylist, newName: newName)){
                result in
                switch result{
                case .success(let graphQLResult):
                    if graphQLResult.errors != nil {
                        alertMessage = "Le nom de la playlist n'a pas pu etre modifié"
                    } else {
                        alertMessage = "Le nom de la playlist a été modifié"
                    }
                    showAlert = true
                    fetchPlaylists()
                    
                case .failure(_):
                    print("Erreur")
                }
            }
        }
        
    }
    func fetchPlaylists() {
        Network.shared.apollo.fetch(query: GetUserPlaylistsQuery(), cachePolicy: CachePolicy.fetchIgnoringCacheData) {  result in
            switch result {
            case .success(let graphQLResult):
                print(graphQLResult.data?.userPlaylists)
                if let newplaylists = graphQLResult.data?.userPlaylists {
                    self.playlists.removeAll()
                    self.playlists.append(contentsOf: newplaylists.compactMap({$0}))
                }
            case .failure(_):
                print("Failure! Error")
            }
        }
    }
    
    func deletePlaylist(at offsets: IndexSet) {
        guard let index = offsets.first else {
            return
        }
        guard let playlistId = playlists[index].id else {
            return
        }
        
        Network.shared.apollo.perform(mutation: RemovePlaylistMutation(id: playlistId)){
            result in
            switch result{
            case .success(let graphQLResult):
                if graphQLResult.errors != nil {
                    alertMessage = "Erreur "
                } else {
                    alertMessage = "La playlist \(playlists[index].name ?? "") a bien été supprimé "
                    playlists.remove(atOffsets: offsets)
                }
                showAlert = true
            case .failure(_):
                print("Erreur")
            }
            
        }
    }
}

#Preview {
    PlaylistView()
}
