//
//  AppointmentResponse.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 6.05.2025.
//
struct AppointmentResponse: Codable {
    let id: Int
    let petId: Int
    let vetId: Int
    let vetName: String
    let petName: String
    let status: String
    let appointmentTime: String
}
