import SwiftUI
import Apollo
import MovieYourselfAPI

struct HomeView: View {
    
//    @Published var films = [AllMoviesQuery.Data.Movie.]
//
    var body: some View {
        NavigationStack{
            VStack{
                TabView{
                    PlaylistView()
                        .tabItem {
                            Image(systemName: "list.and.film")
                            Text("Playlists")
                        }
                    MovieView()
                        .tabItem {
                            Image(systemName: "film")
                            Text("Movies")
                        }
                }
            }
        }
    }
    
    init(){
        //        Network.shared.apollo.fetch(query: LaunchListQuery()) { result in
        //            switch result {
        //            case .success(let graphQLResult):
        //                print("Success! Result: \(graphQLResult)")
        //            case .failure(let error):
        //                print("Failure! Error: \(error)")
        //            }
        //        }
        
        Network.shared.apollo.fetch(query: AllMoviesQuery()){ result in
            switch result {
            case .success(let graphQLResult):
                print("Success! Result: \(graphQLResult.data?.movies?[1]?.title)")
            case .failure(let error):
                print("Failure! Error: \(error)")
            }
        }
    }
}

#Preview {
    HomeView()
}
