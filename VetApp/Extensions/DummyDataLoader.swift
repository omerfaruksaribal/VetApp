//
//  DummyDataLoader.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 6.05.2025.
//
import Foundation

class DummyDataLoader {
    static func load<T: Decodable>(_ filename: String, as type: T.Type) -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            fatalError("File \(filename).json not found.")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            fatalError("Decoding error for \(filename): \(error)")
        }
    }
}
