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

    func createAppointment(request: CreateAppointmentRequest, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/appointments") else { return }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "token") {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let response = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "noData", code: 0)))
                return
            }

            completion(.success(response))
        }.resume()
    }

    func addPet(pet: Pet, ownerId: Int, completion: @escaping (Result<Pet, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/pets") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "name": pet.name,
            "species": pet.species,
            "breed": pet.breed,
            "gender": pet.gender,
            "birthDate": pet.birthDate,
            "ownerId": ownerId
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "noData", code: 0)))
                return
            }

            do {
                let addedPet = try JSONDecoder().decode(Pet.self, from: data)
                completion(.success(addedPet))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func getPetsByOwner(ownerId: Int, completion: @escaping (Result<[Pet], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/pets/owner/\(ownerId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bareer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                print("Network Manager -> Get Pets By Owner Error: \(error)")
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "noData", code: 0)))
                return
            }

            do {
                let pets = try JSONDecoder().decode([Pet].self, from: data)
                completion(.success(pets))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func getAllVets(completion: @escaping (Result<[UserResponse], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/vets") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bareer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                print("Network Manager -> Get All Vets -> Error: \(error)")
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "noData", code: 0)))
                return
            }

            do {
                let vets = try JSONDecoder().decode([UserResponse].self, from: data)
                completion(.success(vets))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func getAppointmentsForVet(vetId: Int, completion: @escaping (Result<[VetAppointment], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/appointments/vet/\(vetId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bareer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                print("Network Manager -> Get Appointments For Vet -> Error: \(error)")
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "noData", code: 0)))
                return
            }

            do {
                let appointments = try JSONDecoder().decode([VetAppointment].self, from: data)
                completion(.success(appointments))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func createDiagnosis(appointmentId: Int, description: String, notes: String, completion: @escaping (Result<Diagnosis, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/diagnoses/create") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "appointmentId": appointmentId,
            "description": description,
            "notes": notes
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "noData", code: 0)))
                return
            }

            do {
                let diagnosis = try JSONDecoder().decode(Diagnosis.self, from: data)
                completion(.success(diagnosis))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func addPrescription(prescription: Prescription, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/prescriptions/add") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            request.httpBody = try JSONEncoder().encode(prescription)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let response = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "noData", code: 0)))
                return
            }

            completion(.success(response))
        }.resume()
    }

}

