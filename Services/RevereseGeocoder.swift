//
//  RevereseGeocoder.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//
//ReverseGeocoder = Converts coordinates to a city name

import CoreLocation
// A tiny helper to turn GPS coordinates into a human-readable city name.
enum ReverseGeocoder {
    // Takes a coordinate and returns a city/country string like "Paris, FR".
    // If we can't figure it out, we return "Current Location".
   
    static func cityName(for coord: CLLocationCoordinate2D) async -> String {
        let geocoder = CLGeocoder() // Apple's class for converting coordinates ↔ addresses
        
        do {
            // Ask iOS to "reverse geocode" the given latitude/longitude into placemark info.
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            )
            
            // If we got at least one placemark back:
            if let p = placemarks.first {
                // Prefer the city name (locality), but fall back to subLocality or administrative area if missing.

                let city = p.locality ?? p.subLocality ?? p.administrativeArea
                // Prefer ISO country code (e.g., "CA"), else full country name.

                let country = p.isoCountryCode ?? p.country
                // Combine non-nil parts into "City, Country"

                return [city, country].compactMap { $0 }.joined(separator: ", ")
            }
        } catch {
            // Ignore errors here; we'll just use the fallback below.
       
        }
        // If reverse geocoding failed or gave nothing, show this default.
        return "Current Location"
    }
}

