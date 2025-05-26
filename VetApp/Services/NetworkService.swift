import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}


// Use network service only for ios15+. if the ios version is less than 15, then async - await won't work.
class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://localhost:8080"
    
    private init() {}
    
    // MARK: - Auth
    func register(request: RegisterRequest) async throws -> String {
        let url = URL(string: "\(baseURL)/auth/register")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingError
        }
        return responseString
    }
    
    func login(email: String, password: String) async throws -> UserResponse {
        let url = URL(string: "\(baseURL)/auth/login")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginData = ["email": email, "password": password]
        urlRequest.httpBody = try JSONEncoder().encode(loginData)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(UserResponse.self, from: data)
    }
    
    // MARK: - Pets
    func getPetsByOwner(ownerId: Int) async throws -> [Pet] {
        let url = URL(string: "\(baseURL)/pets/owner/\(ownerId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Pet].self, from: data)
    }
    
    // MARK: - Appointments
    func getVetAppointments(vetId: Int) async throws -> [AppointmentResponse] {
        let url = URL(string: "\(baseURL)/appointments/vet/\(vetId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([AppointmentResponse].self, from: data)
    }
    
    func completeAppointment(appointmentId: Int) async throws {
        let url = URL(string: "\(baseURL)/appointments/\(appointmentId)/complete")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Failed to complete appointment")
        }
    }
    
    // MARK: - Diagnoses
    func getDiagnosesByPetId(petId: Int) async throws -> [Diagnosis] {
        let url = URL(string: "\(baseURL)/diagnoses/pet/\(petId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Diagnosis].self, from: data)
    }
    
    func createDiagnosis(appointmentId: Int, description: String, notes: String) async throws -> Diagnosis {
        let url = URL(string: "\(baseURL)/diagnoses/create")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let diagnosisData = [
            "appointmentId": appointmentId,
            "description": description,
            "notes": notes
        ] as [String: Any]
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: diagnosisData)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(Diagnosis.self, from: data)
    }
    
    // MARK: - Prescriptions
    func getPrescriptionsByDiagnosisId(_ diagnosisId: Int) async throws -> [Prescription] {
        let url = URL(string: "\(baseURL)/prescriptions/diagnosis/\(diagnosisId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Prescription].self, from: data)
    }
    
    func createPrescription(diagnosisId: Int, medicineName: String, dosage: String, instructions: String) async throws -> Prescription {
        let url = URL(string: "\(baseURL)/prescriptions/create")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prescriptionData = [
            "diagnosisId": diagnosisId,
            "medicineName": medicineName,
            "dosage": dosage,
            "instructions": instructions
        ] as [String: Any]
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: prescriptionData)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(Prescription.self, from: data)
    }
} 
