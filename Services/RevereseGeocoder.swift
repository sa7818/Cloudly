//
//  RevereseGeocoder.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//
import CoreLocation

enum ReverseGeocoder {
    
   
    static func cityName(for coord: CLLocationCoordinate2D) async -> String {
        let geocoder = CLGeocoder() // Apple's class for converting coordinates ↔ addresses
        
        do {
            
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            )
            
           
            if let p = placemarks.first {
               
                let city = p.locality ?? p.subLocality ?? p.administrativeArea
               
                let country = p.isoCountryCode ?? p.country
             
                return [city, country].compactMap { $0 }.joined(separator: ", ")
            }
        } catch {
       
        }
        
   
        return "Current Location"
    }
}

