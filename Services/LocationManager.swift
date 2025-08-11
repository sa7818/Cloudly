//
//  LocationManager.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import CoreLocation
import Combine


final class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var authorization: CLAuthorizationStatus = .notDetermined
    
    private let manager = CLLocationManager()
    
    override init(){
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.requestLocation()
    }
    
  
    func request(){
        switch manager.authorizationStatus{
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case . denied, .restricted:
            break
        @unknown default:
            break
        }
    }
    
   
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        authorization = manager.authorizationStatus
        if authorization == .authorizedWhenInUse || authorization == .authorizedAlways{
            manager.requestLocation()
        }
    }
    
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        coordinate = locations.first?.coordinate
        if let c = coordinate { print("📍 Location:", c.latitude, c.longitude) }
    }
    
   
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("❌ Location error:", error)
    }
}
