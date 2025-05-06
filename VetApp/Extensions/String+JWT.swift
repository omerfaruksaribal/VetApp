//
//  String+JWT.swift
//  VetApp
//
//  Created by Ömerfaruk Saribal on 5.05.2025.
//
import Foundation

extension String {
    func decodeJWTPart() -> [String: Any]? {
        let segments = self.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }

        var base64String = segments[1]
        var requiredLength = (4 * ceil(Double(base64String.count) / 4.0))
        let paddingLength = Int(requiredLength) - base64String.count
        if paddingLength > 0 {
            base64String += String(repeating: "=", count: paddingLength)
        }
        
        guard let data = Data(base64Encoded: base64String, options: []),
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    return nil
        }
        return json
    }
}
