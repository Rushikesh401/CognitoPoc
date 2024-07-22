//
//  ContentView.swift
//  CognitoPoc
//
//  Created by Rushikesh Suradkar on 19/07/24.
//

import SwiftUI

struct ContentView: View {
    @State private var signUpUsername: String = ""
    @State private var signUpPassword: String = ""
    @State private var signUpEmail: String = ""
    @State private var confirmationCode: String = ""
    @State private var showConfirmationField: Bool = false
    @State private var signInUsername: String = ""
    @State private var signInPassword: String = ""
    @State private var refreshToken: String? = ""
    @State private var idToken: String? = ""
    @State private var accessToken: String? = ""
    @State private var errorMessage: String? = ""
    
    var body: some View {
        ScrollView()
        {
            VStack(spacing: 20) {
                // Sign In Section
                Text("Sign In")
                    .font(.largeTitle)
                TextField("Username", text: $signInUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                SecureField("Password", text: $signInPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: {
                    signIn(username: signInUsername, password: signInPassword) { result in
                        switch result {
                        case .success(let tokens):
                            idToken = tokens.idToken
                            accessToken = tokens.accessToken
                            refreshToken = tokens.refreshToken ?? ""
                            errorMessage = "Sign in successful."
                        case .failure(let error):
                            errorMessage = "Sign in failed: \(error.localizedDescription)"
                        }
                    }
                }) {
                    Text("Sign In")
                }
                .padding()
                
                // Sign Up Section
                Text("Sign Up")
                    .font(.largeTitle)
                TextField("Username", text: $signUpUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                SecureField("Password", text: $signUpPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: {
                    signUp(username: signUpUsername, password: signUpPassword) { result in
                        switch result {
                        case .success:
                            showConfirmationField = true
                            errorMessage = "Sign up successful. Please check your email for the confirmation code."
                        case .failure(let error):
                            errorMessage = "Sign up failed: \(error.localizedDescription)"
                        }
                    }
                }) {
                    Text("Sign Up")
                }
                .padding()
                
                if showConfirmationField {
                    TextField("Confirmation Code", text: $confirmationCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button(action: {
                        verifyEmail(confirmationCode: confirmationCode, email: signUpUsername) { result in
                            switch result {
                            case .success:
                                errorMessage = "Email verified successfully. You can now sign in."
                            case .failure(let error):
                                errorMessage = "Email verification failed: \(error.localizedDescription)"
                            }
                        }
                    }) {
                        Text("Verify Email")
                    }
                    .padding()
                }
                
                // Refresh Token Section
                Text("Refresh Token")
                    .font(.largeTitle)
                Button(action: {
                    CognitoPoc.refreshToken(refreshToken: refreshToken ?? "") { result in
                        switch result {
                        case .success(let tokens):
                            idToken = tokens.idToken
                            accessToken = tokens.accessToken
                            refreshToken = tokens.refreshToken ?? refreshToken
                            errorMessage = "Token refreshed successfully."
                        case .failure(let error):
                            errorMessage = "Token refresh failed: \(error.localizedDescription)"
                        }
                    }
                }) {
                    Text("Refresh Token")
                }
                .padding()
                
                Text(errorMessage!)
                    .foregroundColor(.red)
                    .padding()
                
                if let idToken = idToken {
                    Text("ID Token: \(idToken)")
                        .padding()
                }
                
                if let accessToken = accessToken {
                    Text("Access Token: \(accessToken)")
                        .padding()
                }
                
                if let refreshToken = refreshToken {
                    Text("refresh Token: \(refreshToken)")
                        .padding()
                }
                
            }
            .padding()
        }
    }
}
