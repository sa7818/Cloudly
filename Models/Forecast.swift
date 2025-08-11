//
//  Forecast.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//


import Foundation


struct ForecastResponse : Decodable, Sendable {
    let list : [Entry]
    let city: City
    
   
    struct City: Decodable, Sendable {
        let name: String
        let country: String
        let timezone: Int
    }
    
    struct Entry: Decodable, Sendable, Identifiable {
        var id: String { "\(dt)" }
        
        let dt: TimeInterval
        let main: CurrentWeather.Main
        let weather: [CurrentWeather.Weather]
        let wind: CurrentWeather.Wind
        let visibility: Double?
        let pop: Double?
        let dt_txt: String
    }
}


struct DailySummary: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let min: Double
    let max: Double
    let iconId: Int
    let popAvg: Double
    let entries: [ForecastResponse.Entry] 
}
