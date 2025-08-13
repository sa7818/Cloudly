//
//  WeatherIcon.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//
// Maps weather condition codes from the API to local SF Symbols or image assets.

import SwiftUI

// Maps OpenWeather's weather condition codes to SF Symbol icon names.
enum WeatherIcon {
    
    //return the SF Symbol name we should show.
    static func symbol(for code: Int) -> String {
        switch code {
            // Thunderstorm group (200–232) → show cloud with bolt + rain
        case 200...232: return "cloud.bolt.rain.fill"
        
            // Drizzle group (300–321)
        case 300...321: return "cloud.drizzle.fill"
            // Light to moderate rain (500–504)
      
        case 500...504: return "cloud.rain.fill"
        
            // Freezing rain (511) → show snow
        case 511:       return "snow"
            // Heavy rain showers (520–531)
     
        case 520...531: return "cloud.heavyrain.fill"
        
            // Snow group (600–622)
        case 600...622: return "cloud.snow.fill"
        
            // Fog, mist, haze, etc. (701–781)
        case 701...781: return "cloud.fog.fill"
        
            // Clear sky (800)
        case 800:       return "sun.max.fill"
        
            // Few clouds (801)
        case 801:       return "cloud.sun.fill"
        
            // Scattered clouds (802)
        case 802:       return "cloud.fill"
        
            // Broken/overcast clouds (803–804)
        case 803...804: return "smoke.fill"
        
            // Anything else → default to cloud
        default:        return "cloud.fill"
        }
    }
}
