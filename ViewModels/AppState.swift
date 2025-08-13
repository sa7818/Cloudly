//
//  AppState.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//
//AppState = Central place for storing selected city & coordinates
import Foundation
import CoreLocation

//Works with CoreLocation/Coordinates , publishes State to SwiftUI Views
@MainActor
final class AppState: ObservableObject {
    // The city name shown in the navigation bar (defaults to "Current Location")

    @Published var selectedCity: String = "Current Location"
    
    // The map coordinate we’re currently using to load weather for (nil until set)

    @Published var selectedCoordinate: CLLocationCoordinate2D?
    // Simple helper to update both pieces of state at the same time.
    // Views that observe AppState will automatically refresh when these change.
   
    func set(city:String, coord: CLLocationCoordinate2D){
        selectedCity = city
        selectedCoordinate = coord
    }
}
