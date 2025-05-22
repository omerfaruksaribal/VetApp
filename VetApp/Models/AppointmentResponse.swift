//
//  AppointmentResponse.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 6.05.2025.
//
import Foundation

struct AppointmentResponse: Codable {
    let id: Int
    let pet: PetSummaryResponse
    let vet: VetSummaryResponse
    let appointmentTime: String
    let status: String
}

struct PetSummaryResponse: Codable {
    let id: Int
    let name: String
    let species: String
    let breed: String
    let gender: String
    let birthDate: String
}

struct VetSummaryResponse: Codable {
    let id: Int
    let name: String
    let email: String
    let phone: String
}
