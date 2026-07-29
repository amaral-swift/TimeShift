//
//  GeocodingService.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import Foundation

struct GeocodingResult: Decodable, Identifiable {
    let id: Int
    let name: String
    let country: String?
    let admin1: String?
    let timezone: String
}

private struct GeocodingResponse: Decodable {
    let results: [GeocodingResult]?
}

enum GeocodingError: Error {
    case invalidURL
}

enum GeocodingService {
    static func search(name: String) async throws -> [GeocodingResult] {
        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: "pt"),
            URLQueryItem(name: "format", value: "json"),
        ]
        guard let url = components?.url else { throw GeocodingError.invalidURL }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        return decoded.results ?? []
    }
}
