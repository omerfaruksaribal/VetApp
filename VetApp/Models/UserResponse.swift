//
//  LoginResponse.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 5.05.2025.
//

import Foundation

struct UserResponse: Codable {
    let id: Int
    let name: String
    let email: String
    let phone: String
    let role: String
    let appointments: [AppointmentResponse]?
    let specializations: [Specialization]?
}
