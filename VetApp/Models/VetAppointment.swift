//
//  VetAppointment.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 5.05.2025.
//
import Foundation

struct VetAppointment {
    let id: Int
    let petId: Int
    let vetId: Int
    let appointmentTime: Date
    let status: String
    let pet: Pet?
    let owner: UserReference?
    
    init(from response: AppointmentResponse) {
        self.id = response.id
        self.petId = response.pet.id
        self.vetId = response.vet.id
        self.appointmentTime = ISO8601DateFormatter().date(from: response.appointmentTime) ?? Date()
        self.status = response.status
        self.pet = Pet(
            id: response.pet.id,
            name: response.pet.name,
            species: response.pet.species,
            breed: response.pet.breed,
            gender: response.pet.gender,
            birthDate: response.pet.birthDate,
            registeredAt: response.pet.birthDate,
            owner: nil
        )
        self.owner = UserReference(
            id: response.vet.id,
            name: response.vet.name
        )
    }
}
