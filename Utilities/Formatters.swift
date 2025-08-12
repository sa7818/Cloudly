//
//  Formatters.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import Foundation

// A central place to keep all our formatters and formatting helper functions.
// This way, we don't repeat formatting code in multiple places.
enum Fmt {
    
    // Formats a Date into something like "Tue, Aug 8".
    // Used for displaying days in the forecast.
    static let day : DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d" // EEE = short weekday, MMM = short month
        return df
    }()
    // Formats a Date into something like "3PM".
    // Used for displaying hourly forecast times.
    static let hour : DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "ha" // h = hour (1–12), a = AM/PM
        return df
    }()
    
    // Formats a temperature in Celsius (Double) into a whole number string.
    // Example: 21.6 -> "22"
    static func temp(_ c : Double) -> String {
        String(format:"%.0f", c)
    }
    
    // Formats a probability (0.0–1.0) into a percentage string.
    // Example: 0.25 -> "25%"
    static func percent(_ p : Double) -> String {
        String(format:"%.0f%%", p*100)
    }
}
