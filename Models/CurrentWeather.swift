//
//  CurrentWeather.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//
//CurrentWeather.swift — Defines the data structure for the current conditions.

import Foundation

// Decodes JSON into strongly-typed models (no logic here)
// Using "Current Weather Data" JSON format from https://openweathermap.org/current
// Top-level container that matches the `/weather` response.
struct CurrentWeather: Decodable, Sendable {
    /**
     Example to match the API:
     "weather": [
          {
             "id": 501,
             "main": "Rain",
             "description": "moderate rain",
             "icon": "10d"
          }
     */
    struct Weather: Decodable, Sendable {
        let id: Int  // OpenWeather condition code
        let main: String //Short label like "Rain", "Clouds"
        let description: String
        let icon: String //SF Symbols
    }
    /**
     Example to match the API :
     "main": {
     "temp": 284.2,
     "feels_like": 282.93,
     "temp_min": 283.06,
     "temp_max": 286.82,
     "pressure": 1021,
     "humidity": 60,
     "sea_level": 1021,
     "grnd_level": 910
  },
     */
    struct Main: Decodable, Sendable {
        let temp: Double //°C
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let pressure: Double //hPa
        let humidity: Double
    }
    /**
     Example to match the API:
     "wind": {
     "speed": 4.09,
     "deg": 121,
     "gust": 3.47
  },
     */
    struct Wind: Decodable, Sendable {
        let speed: Double
        let deg: Double? // Wind direction in degrees (0–360)
    }
    /**
     Example to match the API:
     "clouds": {
          "all": 83
       },
     */
    struct Clouds: Decodable, Sendable {
        let all: Int
    }

    //  Top-level fields from the JSON root
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let clouds: Clouds // Cloudiness percent
    let visibility: Double // Visibility in meters
    let name: String // City name
}
