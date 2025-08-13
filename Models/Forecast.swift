//
//  Forecast.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//
//Forecast.swift — Represents daily & hourly forecast entries.

import Foundation
//Call 5 day / 3 hour forecast data https://openweathermap.org/forecast5
// The API returns a list of time-based weather entries + city info.

struct ForecastResponse : Decodable, Sendable {
    let list : [Entry] // Array of forecast data points
    let city: City
   
    struct City: Decodable, Sendable {
        let name: String
        let country: String // Country code
        let timezone: Int // Timezone offset in seconds from UTC
    }
    //the weather at a specific date/time
    struct Entry: Decodable, Sendable, Identifiable {
        var id: String { "\(dt)" }
        
        let dt: TimeInterval // Forecast time as UNIX timestamp
        let main: CurrentWeather.Main // Temperature/pressure/humidity
        let weather: [CurrentWeather.Weather] // Weather condition(s)
        let wind: CurrentWeather.Wind
        let visibility: Double?
        let pop: Double? //Probability of precipitation
        let dt_txt: String  // Human-readable datetime text from API
    }
}

// A daily summary we create by grouping multiple forecast entries for the same day.
// For UI display.
struct DailySummary: Identifiable, Sendable {
    let id = UUID() // Unique ID for SwiftUI lists
    let date: Date
    let min: Double
    let max: Double
    let iconId: Int // Icon ID representing the "main" weather of the
    let popAvg: Double // Average chance of precipitation for the day
    let entries: [ForecastResponse.Entry] // All forecast entries for that day
}
