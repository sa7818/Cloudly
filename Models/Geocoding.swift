//
//  Geocoding.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//


import Foundation


struct GeoResult: Identifiable, Decodable, Sendable {
    
 
    let id: UUID

    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
  
    private enum CodingKeys: String, CodingKey {
        case name, lat, lon, country, state
    }

  
    init(name: String, lat: Double, lon: Double, country: String, state: String?) {
        self.id = UUID()
        self.name = name
        self.lat = lat
        self.lon = lon
        self.country = country
        self.state = state
    }

   
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try c.decode(String.self, forKey: .name)
        self.lat = try c.decode(Double.self, forKey: .lat)
        self.lon = try c.decode(Double.self, forKey: .lon)
        self.country = try c.decode(String.self, forKey: .country)
        self.state = try c.decodeIfPresent(String.self, forKey: .state) 
    }
}
