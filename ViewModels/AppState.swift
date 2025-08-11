//
//  AppState.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import Foundation
import CoreLocation


@MainActor
final class AppState: ObservableObject {
   
    @Published var selectedCity: String = "Current Location"
    
   
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    
   
    func set(city:String, coord: CLLocationCoordinate2D){
        selectedCity = city
        selectedCoordinate = coord
    }
}
