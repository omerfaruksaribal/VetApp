//
//  VetAppointment.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 5.05.2025.
//

// PROBLEMLER VAR DÜZELT
struct VetAppointment: Codable {
    let id: Int
    let petName: String
    let ownerName: String
    let date: String
    let status: String // PENDING, COMPLETED
}
