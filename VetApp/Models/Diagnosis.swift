//
//  Diagnosis.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 6.05.2025.
//
import Foundation

struct Diagnosis: Codable {
    let id: Int
    let appointmentId: Int
    let description: String
    let notes: String
    let diagnosedAt: String
    let prescriptions: [Prescription]
}
