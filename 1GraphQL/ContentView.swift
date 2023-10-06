import SwiftUI
import Apollo
import MovieYourself

struct ContentView: View {
    
    @State private var usernameTextField: String = ""
    @State private var passwordTextField: String = ""
    @State private var isNotLogged = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isNotLogged {
                    Text("MovieYourself 🍿").font(.title)
                    LoginView(username: $usernameTextField,
                              password: $passwordTextField,
                              isNotLogged: $isNotLogged)
                } else{
                    HomeView()
                }
            }
        }
    }
}


struct LoginView:View{
    @Binding var username: String
    @Binding var password: String
    @Binding var isNotLogged: Bool
    
    @State private var showAlert = false
    
    var body: some View{
        NavigationView {
            VStack {
                TextField("Utilisateur", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                
                SecureField("Mot de Passe", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Se connecter") {
                    login()
                }.buttonStyle(.borderedProminent)
                .padding()
                
                NavigationLink(destination: SignUpView(), label: {
                    Text("Pas de compte ? Inscrivez-vous ")
                })
            }
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text("Erreur"),
                message: Text("Utilisateur ou mot de passe incorrect"),
                dismissButton: .default(Text("OK")) {
                    showAlert = !showAlert
                }
            )
        }
    }
    
    func login(){
        let pwd = PasswordUtilities.hashPassword(password: password)
        Network.shared.apollo.fetch(query: LoginQuery(mail: username, password: pwd)){  result in
            switch result {
            case .success(let graphQLResult):
                print(graphQLResult.data?.login?.id)
                if graphQLResult.errors != nil{
                    isNotLogged = true
                    showAlert = true
                }else if graphQLResult.data?.login?.id != nil{
                    isNotLogged = false
                }
            case .failure(let error):
                isNotLogged = true
                print("Failure! Error: \(error)")
            }
        }
    }
}

#Preview {
    NavigationView{
        ContentView()
    }
}
