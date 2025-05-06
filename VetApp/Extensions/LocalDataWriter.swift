//
//  LocalDataWriter.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 6.05.2025.
//
import Foundation

class LocalDataWriter {
    static func append<T: Codable>(_ filename: String, item: T) {
        let fileManager = FileManager.default
        guard let url = fileURL(for: filename) else { return }

        var items: [T] = []
        if let data = try? Data(contentsOf: url) {
            items = (try? JSONDecoder().decode([T].self, from: data)) ?? []
        }

        items.append(item)

        if let updatedData = try? JSONEncoder().encode(items) {
            try? updatedData.write(to: url)
        }
    }

    static func fileURL(for filename: String) -> URL? {
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        return docs?.appendingPathComponent("\(filename).json")
    }
}
