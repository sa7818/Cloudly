//
//  WeatherIcon.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import SwiftUI


enum WeatherIcon {
    
    
    static func symbol(for code: Int) -> String {
        switch code {
       
        case 200...232: return "cloud.bolt.rain.fill"
        
      
        case 300...321: return "cloud.drizzle.fill"
        
      
        case 500...504: return "cloud.rain.fill"
        
     
        case 511:       return "snow"
        
     
        case 520...531: return "cloud.heavyrain.fill"
        
      
        case 600...622: return "cloud.snow.fill"
        
       
        case 701...781: return "cloud.fog.fill"
        
      
        case 800:       return "sun.max.fill"
        
       
        case 801:       return "cloud.sun.fill"
        
      
        case 802:       return "cloud.fill"
        
     
        case 803...804: return "smoke.fill"
        
     
        default:        return "cloud.fill"
        }
    }
}
