//
//  Prescription.swift.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 6.05.2025.
//
import Foundation

struct Prescription: Codable {
    let id: Int
    let diagnosisId: Int?
    let medicineName: String
    let dosage: String
    let instructions: String
}

