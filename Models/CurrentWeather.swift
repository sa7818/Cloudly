//
//  CurrentWeather.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//


import Foundation




struct CurrentWeather: Decodable, Sendable {
    
   
    struct Weather: Decodable, Sendable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Main: Decodable, Sendable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let pressure: Double
        let humidity: Double
    }
    
    struct Wind: Decodable, Sendable {
        let speed: Double
        let deg: Double?
    }
    
    struct Clouds: Decodable, Sendable {
        let all: Int
    }

   
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let clouds: Clouds
    let visibility: Double
    let name: String          
}
