//
//  VetAppointment.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 5.05.2025.
//
struct VetAppointment: Codable {
    let id: Int
    let petId: Int
    let vetId: Int
    let vetName: String
    let petName: String
    let status: String
    let appointmentTime: String
}
