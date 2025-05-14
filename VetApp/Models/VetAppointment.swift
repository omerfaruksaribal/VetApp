//
//  VetAppointment.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 5.05.2025.
//
struct VetAppointment: Codable {
    let id: Int
    let pet: PetInfo
    let vet: VetInfo
    let appointmentTime: String
    let status: String

    struct PetInfo: Codable {
        let id: Int
        let name: String
    }

    struct VetInfo: Codable {
        let id: Int
        let name: String
    }

    var petName: String { pet.name }
    var vetName: String { vet.name }
}
