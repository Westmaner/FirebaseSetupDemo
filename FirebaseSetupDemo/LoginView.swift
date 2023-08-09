//
//  LoginView.swift
//  TTTMultiplayer
//
//  Created by Tim Yoon on 8/8/23.
//

import SwiftUI
import FirebaseAuth

class LoginVM: ObservableObject {
    @Published private(set) var isLoggedIn: Bool
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var message = ""
    @Published var isShowingAlert = false
    @Published private(set) var user: User?
    
    
    init() {
        
        if Auth.auth().currentUser != nil {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
    
    func setupListener() {
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.user = user
            
            if user != nil {
                self?.isLoggedIn = true
            } else {
                self?.isLoggedIn = false
            }
        }
    }
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            
            if let error {
                self?.message = error.localizedDescription
                self?.isShowingAlert = true
//                self?.isLoggedIn = false
            } else {
                self?.message = "Login Successful"
//                self?.isLoggedIn = true
            }
        }
    }
    
    func signup() {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self ] authResult, error in
            if let error {
                self?.message = error.localizedDescription
                self?.isShowingAlert = true
            } else {
                self?.message = "Login Successful"
                self?.isShowingAlert = true
            }
        }
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.email = ""
            self.password = ""
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            message = "Error signing out: \(signOutError)"
            isShowingAlert = true
        }
    }
}
struct LoginView: View {
    @ObservedObject var vm: LoginVM
    
    var body: some View {
        ZStack{
            backgroundImage
            
            VStack {
                inputTextBoxes
                
                loginAndSignUpButtons
                    .alert(vm.message, isPresented: $vm.isShowingAlert) {
                        Button("OK", role: .cancel) { }
                    }
            }
            .padding(.horizontal)
        }
    }

    var loginAndSignUpButtons : some View {
        HStack {
            Button {
                vm.login()
            } label: {
                Text("Login")
            }
            .padding(.trailing, 30)
            
            Button {
                vm.signup()
            } label: {
                Text("Sign Up")
            }
        }
        .buttonStyle(.borderedProminent)
    }
    var inputTextBoxes: some View {
        VStack {
            TextField("Email", text: $vm.email)
            SecureField("Password", text: $vm.password)
        }
        .textFieldStyle(.roundedBorder)
        .shadow(radius: 4, x: 4, y: 4)
        .padding(.bottom, 30)
    }
    var backgroundImage: some View {
        Color.primary
            .overlay {
                Image("loginPhoto")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .blur(radius: 5)
            }
            .ignoresSafeArea()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(vm: LoginVM())
    }
}
