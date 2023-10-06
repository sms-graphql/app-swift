import SwiftUI
import Apollo
import MovieYourself

struct CreatePlaylistView: View {
    
    @State private var namePlaylist: String = ""
    
    @Binding var isSheetPresented: Bool
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
            VStack{
                TextField("Nom de la playlist", text: $namePlaylist).textFieldStyle(.roundedBorder)
                Button(action: {
//                    isSheetPresented = false
                    createPlaylist()
                }, label: {
                    Text("Créer la playlist")
                }).buttonStyle(.borderedProminent)
            }.padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Playlist"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        isSheetPresented = false
                    }
                )
            }
    }
    
    func createPlaylist(){
        if namePlaylist.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            Network.shared.apollo.perform(mutation: CreatePlaylistMutation(playlistName: namePlaylist)){
                result in
                switch result{
                            case .success(let graphQLResult):
                                if graphQLResult.errors != nil {
                                    alertMessage = "Erreur: Playlist non crée ❌"
                                } else {
                                    alertMessage = "La playlist \(namePlaylist) a bien été creer 🍿"
                                }
                                showAlert = true
                
                            case .failure(_):
                                print("Erreur")
                            }
            }
        }
    }
}

#Preview {
    CreatePlaylistView(isSheetPresented: .constant(true))
}
