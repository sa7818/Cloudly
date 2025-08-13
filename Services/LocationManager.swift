//
//  LocationManager.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//
//LocationManager = Manages GPS permission & one-time location retrieval

import CoreLocation
import Combine

//  Wrapper around CLLocationManager.
//  ask for location permission, get one GPS fix, and publish it
final class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    // The latest coordinate we got from the device
    @Published var coordinate: CLLocationCoordinate2D?
    // The current authorization state (notDetermined / authorized / denied / etc.).
    @Published var authorization: CLAuthorizationStatus = .notDetermined
    // Apple's location manager that  talks to Core Location.
    private let manager = CLLocationManager()
    
    override init(){
        super.init()
        manager.delegate = self // Receive callbacks here
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        // ^ "Coarse" accuracy is enough for weather; saves battery and is quicker.
        manager.requestLocation() // Ask for ONE location update right away (one-shot)
    }
    
    // Called from the UI when the user taps "use my location".
    // This checks permission and either requests it or fetches the location once.
    func request(){
        switch manager.authorizationStatus{
        case .notDetermined: // User hasn't decided yet → ask nicely
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: // We already have permission → get location
            manager.requestLocation()
        case . denied, .restricted:  // User said no or not allowed → do nothing
            break
        @unknown default:
            break
        }
    }
    
    // iOS will call this when the permission state changes (e.g., user taps "Allow").
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        // If allowed, immediately try to get one location fix.
        authorization = manager.authorizationStatus
        if authorization == .authorizedWhenInUse || authorization == .authorizedAlways{
            manager.requestLocation()
        }
    }
    
    // iOS will call this when it has new location(s).
    // We take the first one and publish its coordinate for the rest of the app.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        coordinate = locations.first?.coordinate
        if let c = coordinate { print("📍 Location:", c.latitude, c.longitude) }
    }
    // iOS will call this if getting the location failed.
    // We just log it; the UI can keep showing the search box or a friendly message.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("❌ Location error:", error)
    }
}
