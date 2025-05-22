//
//  RegisterRequest.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 5.05.2025.
//
import Foundation

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
    let phone: String
    let role: String // "OWNER" OR "VET"
}
