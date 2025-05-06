//
//  DiagnosedPatient.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 5.05.2025.
//
struct DiagnosedPatient: Codable {
    let petName: String
    let diagnosis: String
    let prescription: [String]
}
