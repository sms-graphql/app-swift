import SwiftUI
import Apollo

struct ContentView: View {
    
    @State private var usernameTextField: String = ""
    @State private var passwordTextField: String = ""
    
    @State private var isLogged = false
    
    var body: some View {
        NavigationView {
            VStack {
                LoginView(username: $usernameTextField,
                          password: $passwordTextField,
                          isLoggedIn: $isLogged)
            }
        }
    }
}


struct LoginView:View{
    @Binding var username: String
    @Binding var password: String
    @Binding var isLoggedIn: Bool
    
    var body: some View{
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Log In") {
            }
            .padding()
        }
    }
}

#Preview {
    NavigationView{
        ContentView()
    }
}
