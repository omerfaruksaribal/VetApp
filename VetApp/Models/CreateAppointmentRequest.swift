//
//  CreateAppointmentRequest.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 6.05.2025.
//
struct CreateAppointmentRequest: Codable {
    let petId: Int
    let vetId: Int
    let appointmentTime: String  // ISO 8601 format: "2025-05-06T14:00:00"
}
