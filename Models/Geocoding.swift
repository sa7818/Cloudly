//
//  Geocoding.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//
//Geocoding.swift — Represents search results for city name → coordinates.

import Foundation

//Decodes JSON into strongly-typed models.
// Represents one location result from OpenWeather's Geocoding API.
// We use this when searching for cities by name.
struct GeoResult: Identifiable, Decodable, Sendable {
    
    // Generate our own unique row ID because the API's geocoding JSON does not have an "id" field.
    let id: UUID
    // Basic info about the location from the API:
    let name: String
    let lat: Double // Latitude of the location
    let lon: Double  // Longitude of the location
    let country: String // Country code
    let state: String?
    // Only these keys are expected; anything else in the JSON is ignored.
    private enum CodingKeys: String, CodingKey {
        case name, lat, lon, country, state
    }

    // Convenience initializer so we can create a GeoResult manually if needed.
    init(name: String, lat: Double, lon: Double, country: String, state: String?) {
        self.id = UUID() // Always generate a fresh unique ID
        self.name = name
        self.lat = lat
        self.lon = lon
        self.country = country
        self.state = state
    }

    // Custom initializer for decoding from JSON.
    // This matches the API's fields and also generates a UUID for the `id`.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID() // Still generate a new ID here because API doesn’t provide one
        self.name = try c.decode(String.self, forKey: .name)
        self.lat = try c.decode(Double.self, forKey: .lat)
        self.lon = try c.decode(Double.self, forKey: .lon)
        self.country = try c.decode(String.self, forKey: .country)
        self.state = try c.decodeIfPresent(String.self, forKey: .state) 
    }
}
