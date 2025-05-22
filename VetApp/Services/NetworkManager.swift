import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:8080"
    
    private init() {}
    
    // MARK: - Auth
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
    
    // MARK: - Appointments
    func getVetAppointments(vetId: Int, completion: @escaping (Result<[AppointmentResponse], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/appointments/vet/\(vetId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "noData", code: 0)))
                return
            }
            
            do {
                let appointments = try JSONDecoder().decode([AppointmentResponse].self, from: data)
                completion(.success(appointments))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getAppointmentsByPetId(petId: Int, completion: @escaping (Result<[AppointmentResponse], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/appointments/\(petId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "noData", code: 0)))
                return
            }
            
            do {
                let appointments = try JSONDecoder().decode([AppointmentResponse].self, from: data)
                completion(.success(appointments))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func completeAppointment(appointmentId: Int, completion: @escaping (Result<AppointmentResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/appointments/\(appointmentId)/complete") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
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
                let appointment = try JSONDecoder().decode(AppointmentResponse.self, from: data)
                completion(.success(appointment))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Diagnoses
    func getDiagnosesByPetId(petId: Int, completion: @escaping (Result<[Diagnosis], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/diagnoses/pet/\(petId)") else {
            print("Error: Invalid URL for getting diagnoses by pet ID")
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for getting diagnoses"])))
            return
        }
        
        print("Fetching diagnoses for pet ID: \(petId)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error fetching diagnoses: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("Error: No data received from server")
                completion(.failure(NSError(domain: "noData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
            
            do {
                let diagnoses = try JSONDecoder().decode([Diagnosis].self, from: data)
                print("Successfully fetched \(diagnoses.count) diagnoses")
                completion(.success(diagnoses))
            } catch {
                print("Error decoding diagnoses: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createDiagnosis(appointmentId: Int, description: String, notes: String, completion: @escaping (Result<Diagnosis, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/diagnoses/create") else {
            print("Error: Invalid URL for diagnosis creation")
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for diagnosis creation"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let diagnosisData = [
            "appointmentId": appointmentId,
            "description": description,
            "notes": notes
        ] as [String: Any]
        
        print("Creating diagnosis with data: \(diagnosisData)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: diagnosisData)
        } catch {
            print("Error encoding diagnosis data: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error creating diagnosis: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("Error: No data received from server")
                completion(.failure(NSError(domain: "noData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
            
            do {
                let diagnosis = try JSONDecoder().decode(Diagnosis.self, from: data)
                print("Successfully created diagnosis with ID: \(diagnosis.id)")
                completion(.success(diagnosis))
            } catch {
                print("Error decoding diagnosis response: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Prescriptions
    func getPrescriptionsByDiagnosisId(_ diagnosisId: Int, completion: @escaping (Result<[Prescription], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/prescriptions/\(diagnosisId)") else {
            print("Error: Invalid URL for getting prescriptions")
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for getting prescriptions"])))
            return
        }
        
        print("Fetching prescriptions for diagnosis ID: \(diagnosisId)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error fetching prescriptions: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("Error: No data received from server")
                completion(.failure(NSError(domain: "noData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
            
            do {
                let prescriptions = try JSONDecoder().decode([Prescription].self, from: data)
                print("Successfully fetched \(prescriptions.count) prescriptions")
                completion(.success(prescriptions))
            } catch {
                print("Error decoding prescriptions: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createPrescription(diagnosisId: Int, medicineName: String, dosage: String, instructions: String, completion: @escaping (Result<Prescription, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/prescriptions/add") else {
            print("Error: Invalid URL for prescription creation")
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for prescription creation"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prescriptionData = [
            "diagnosisId": diagnosisId,
            "medicineName": medicineName,
            "dosage": dosage,
            "instructions": instructions
        ] as [String: Any]
        
        print("Creating prescription with data: \(prescriptionData)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: prescriptionData)
        } catch {
            print("Error encoding prescription data: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error creating prescription: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("Error: No data received from server")
                completion(.failure(NSError(domain: "noData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
            
            do {
                let prescription = try JSONDecoder().decode(Prescription.self, from: data)
                print("Successfully created prescription with ID: \(prescription.id)")
                completion(.success(prescription))
            } catch {
                print("Error decoding prescription response: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Pets
    func createPet(pet: Pet, ownerId: Int, completion: @escaping (Result<Pet, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/pets") else {
            print("Error: Invalid URL for pet creation")
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for pet creation"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let petData = [
            "name": pet.name,
            "species": pet.species,
            "breed": pet.breed,
            "gender": pet.gender,
            "birthDate": pet.birthDate,
            "ownerId": ownerId
        ] as [String: Any]
        
        print("Creating pet with data: \(petData)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: petData)
        } catch {
            print("Error encoding pet data: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error creating pet: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("Error: No data received from server")
                completion(.failure(NSError(domain: "noData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
            
            do {
                let savedPet = try JSONDecoder().decode(Pet.self, from: data)
                print("Successfully created pet with ID: \(savedPet.id ?? -1)")
                completion(.success(savedPet))
            } catch {
                print("Error decoding pet response: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getPetsByOwner(ownerId: Int, completion: @escaping (Result<[Pet], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/pets/owner/\(ownerId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
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
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
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
}

