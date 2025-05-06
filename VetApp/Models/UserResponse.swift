//
//  LoginResponse.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 5.05.2025.
//

struct UserResponse: Codable {
    let id: Int
    let name: String
    let email: String
    let password: String
    let role: String
    let phone: String
    let appointments: [VetAppointment]
    let specializations: [Specializations]
}
