//
//  SignUpView.swift
//  1GraphQL
//
//  Created by Zinedine Megnouche on 12/10/2023.
//

import SwiftUI
import Apollo
import MovieYourself

struct SignUpView: View {
    
    @State private var selectedDate = Date()
    @State private var showAlert: Bool = false
    @State private var messageAlert: String = ""
    
    @State private var mailTextField: String = ""
    @State private var firstnameTextField: String = ""
    @State private var lastnameTextField: String = ""
    @State private var passwordTextField: String = ""
    @State private var confirmPasswordTextField: String = ""
    @State private var phoneTextField: String = ""
    @State private var adressTextField: String = ""
    @State private var dateOfBirth: String = ""
    
    
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 20){
                Text("Inscription").font(.title).bold()
                TextField("Prenom", text: $firstnameTextField)
                    .textFieldStyle(.roundedBorder)
                TextField("Nom", text: $lastnameTextField)
                    .textFieldStyle(.roundedBorder)
                TextField("Téléphone", text: $phoneTextField)
                    .textFieldStyle(.roundedBorder)
                TextField("Adresse", text: $adressTextField)
                    .textFieldStyle(.roundedBorder)
                
                DatePicker("Date de naissance", selection: $selectedDate, displayedComponents: .date)
                    .padding()
                TextField("Mail", text: $mailTextField)
                    .textFieldStyle(.roundedBorder)
                SecureField("Mot de passe", text: $passwordTextField)
                    .textFieldStyle(.roundedBorder)
                SecureField("Confirmer mot de passe", text: $confirmPasswordTextField)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: {
                    if isFieldsOk(){
                        createUser()
                    }
                    else {
                        showAlert = true
                    }
                }, label: {
                    Text("S'inscrire")
                }).buttonStyle(.borderedProminent)
            }.padding()
                .alert(isPresented: $showAlert, content: {
                    Alert(
                        title: Text("Inscription"),
                        message: Text(messageAlert),
                        dismissButton: .default(Text("OK"))
                    )
                })
        }
    }
    
    func isFieldsOk() -> Bool{
        
        if firstnameTextField.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            messageAlert = "Le champ Prénom est incorrecte"
            return false
        }
        
        if lastnameTextField.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            messageAlert = "Nom est incorrecte"
            return false
        }
        
        if phoneTextField.trimmingCharacters(in: .whitespacesAndNewlines).count != 10
        {
            messageAlert = "Téléphone est incorrecte"
            return false
            
        }
        if adressTextField.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            messageAlert = "Adresse est incorrecte"
            return false
        }
        if !mailTextField.trimmingCharacters(in: .whitespacesAndNewlines).contains("@"){
            messageAlert = "Mail est incorrecte"
            return false
        }
        
        if !PasswordUtilities.isPasswordValid(passwordTextField){
            messageAlert = "Mot de passe n'est pas assez sécurisé"
            return false
        }
        if passwordTextField != confirmPasswordTextField {
            messageAlert = "Mot de passe différents"
            return false
        }
        
        if !InputUtilities.isUserOver18(dateOfBirth: selectedDate)
        {
            messageAlert = "Utilisateur mineur, Vous devez avoir 18 ans"
            return false
        }
        return true
        
    }
    
    func createUser(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let birthDay = selectedDate
        let dateOfBirth = dateFormatter.string(from: birthDay)
        let pwd = PasswordUtilities.hashPassword(password: passwordTextField)
        
        Network.shared.apollo.perform(mutation: CreateUserMutation(firstname: firstnameTextField, lastname: lastnameTextField, email: mailTextField, address: adressTextField, password: pwd, phoneNumber: phoneTextField, dateOfBirth: dateOfBirth)){ result in
            switch result{
            case .success(let graphQLResult):
                if graphQLResult.errors != nil {
                    messageAlert = "Erreur l'utilisateur n'a pas pu être crée n'a pas pu etre ajouté a la playlist ❌"
                } else {
                    messageAlert = "L'utilisateur a été crée ✅"
                }
                showAlert = true
                
            case .failure(_):
                print("Erreur")
            }
        }
    }
}

#Preview {
    SignUpView()
}
