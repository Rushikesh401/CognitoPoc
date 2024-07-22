//
//  CognitoAuthService.swift
//  CognitoPoc
//
//  Created by Rushikesh Suradkar on 19/07/24.
//

import Foundation

struct CognitoConfig {
    static let userPoolId = "YourUserPoolId"
    static let clientId = "ClientID"
    static let region = "YourRegion"
    static let signUpEndpoint = "https://cognito-idp.\(region).amazonaws.com/"
}

struct CognitoTokens {
    let idToken: String
    let accessToken: String
    let refreshToken: String?
}

func signUp(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    let url = URL(string: CognitoConfig.signUpEndpoint)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
    request.addValue("AWSCognitoIdentityProviderService.SignUp", forHTTPHeaderField: "X-Amz-Target")

    let body: [String: Any] = [
        "ClientId": CognitoConfig.clientId,
        "Username": username,
        "Password": password,
        "UserAttributes": [
            ["Name": "email", "Value": username]
        ]
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
        completion(.failure(error))
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }

        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
            print(jsonResponse) // handle response as needed
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    task.resume()
}

func verifyEmail(confirmationCode: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) {
    let url = URL(string: CognitoConfig.signUpEndpoint)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
    request.addValue("AWSCognitoIdentityProviderService.ConfirmSignUp", forHTTPHeaderField: "X-Amz-Target")

    let body: [String: Any] = [
        "ClientId": CognitoConfig.clientId,
        "Username": email,
        "ConfirmationCode": confirmationCode
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
        completion(.failure(error))
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }

        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
            print(jsonResponse) // handle response as needed
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    task.resume()
}

func signIn(username: String, password: String, completion: @escaping (Result<CognitoTokens, Error>) -> Void) {
    let url = URL(string: CognitoConfig.signUpEndpoint)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
    request.addValue("AWSCognitoIdentityProviderService.InitiateAuth", forHTTPHeaderField: "X-Amz-Target")

    let body: [String: Any] = [
        "AuthParameters": [
            "USERNAME": username,
            "PASSWORD": password
        ],
        "AuthFlow": "USER_PASSWORD_AUTH",
        "ClientId": CognitoConfig.clientId
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
        completion(.failure(error))
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }

        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let authenticationResult = jsonResponse["AuthenticationResult"] as? [String: Any],
               let idToken = authenticationResult["IdToken"] as? String,
               let accessToken = authenticationResult["AccessToken"] as? String {
                let refreshToken = authenticationResult["RefreshToken"] as? String
                let tokens = CognitoTokens(idToken: idToken, accessToken: accessToken, refreshToken: refreshToken)
                completion(.success(tokens))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response received"])))
            }
        } catch {
            completion(.failure(error))
        }
    }

    task.resume()
}

func refreshToken(refreshToken: String, completion: @escaping (Result<CognitoTokens, Error>) -> Void) {
    let url = URL(string: CognitoConfig.signUpEndpoint)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
    request.addValue("AWSCognitoIdentityProviderService.InitiateAuth", forHTTPHeaderField: "X-Amz-Target")

    let body: [String: Any] = [
        "AuthParameters": [
            "REFRESH_TOKEN": refreshToken
        ],
        "AuthFlow": "REFRESH_TOKEN_AUTH",
        "ClientId": CognitoConfig.clientId
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
        completion(.failure(error))
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }

        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let authenticationResult = jsonResponse["AuthenticationResult"] as? [String: Any],
               let idToken = authenticationResult["IdToken"] as? String,
               let accessToken = authenticationResult["AccessToken"] as? String {
                let newRefreshToken = authenticationResult["RefreshToken"] as? String
                let tokens = CognitoTokens(idToken: idToken, accessToken: accessToken, refreshToken: newRefreshToken ?? refreshToken)
                completion(.success(tokens))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response received"])))
            }
        } catch {
            completion(.failure(error))
        }
    }

    task.resume()
}
