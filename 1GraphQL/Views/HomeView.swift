import SwiftUI
import Apollo
import MovieYourself

struct HomeView: View {

    var body: some View {
        NavigationStack{
            VStack{
                TabView{
                    MovieView()
                        .tabItem {
                            Image(systemName: "film")
                            Text("Movies")
                        }
                    PlaylistView()
                        .tabItem {
                            Image(systemName: "list.and.film")
                            Text("Playlists")
                        }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

