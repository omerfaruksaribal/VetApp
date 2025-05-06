//
//  NetworkManager.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 5.05.2025.
//
import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    let baseURL = "http://localhost:8080"

    func login(email: String, password: String, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/login") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                print(error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid Response", code: 0)))
                return
            }

            guard httpResponse.statusCode == 200 else {
                let code = httpResponse.statusCode
                completion(.failure(NSError(domain: "HTTPError", code: code, userInfo: [NSLocalizedDescriptionKey: "Sunucu \(code) hatası"])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "EmptyResponse", code: 0)))
                return
            }

            do {
                let result = try JSONDecoder().decode(UserResponse.self, from: data)
                completion(.success(result))
            } catch {
                print("Login decode error:", error)
                completion(.failure(error))
            }
        }.resume()
    }

    func register(user: RegisterRequest, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/register") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(user)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let responseText = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "EmptyOrInvalid", code: 0)))
                return
            }
            print(String(data: data, encoding: .utf8) ?? "Veri boş")

            completion(.success(responseText))
        }.resume()
    }

}
