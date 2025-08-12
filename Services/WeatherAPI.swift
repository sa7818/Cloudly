//
//  WeatherAPI.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import Foundation
import CoreLocation
// Simple list of error types we might hit while talking to the API.
// - missingKey: we don't have an API key
// - badURL: our final URL couldn't be built
// - network: the server replied with a non-200 status code or network failed
// - decoding: failed to turn JSON into our Swift structs (thrown by JSONDecoder)
enum WeatherAPIError : Error { case missingKey, badURL, network, decoding }
// This is our tiny "network client" for OpenWeather.
// We use a singleton (shared) so the whole app reuses one instance.

final class WeatherAPI: @unchecked Sendable {
    static let shared = WeatherAPI()
    private init(){}
    // Reads the API key from Secrets.plist in the app bundle.
    // If anything goes wrong, we return an empty string and later throw `missingKey`.
    private var apiKey: String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = plist["OPENWEATHER_API_KEY"] as? String,
            !key.isEmpty
        else { return "" }
        return key
    }
    // Base URLs for OpenWeather:
    // - `base` is for current weather + forecast
    // - `geoBase` is for city search (geocoding)
  
    private let base = "https://api.openweathermap.org/data/2.5"
    private let geoBase = "https://api.openweathermap.org/geo/1.0"
    
    // Core helper that sends a request:
    // - Adds our API key and units=metric to the URL
    // - Performs the network call
    // - Checks for HTTP 200 OK
    // - Returns the raw Data if everything is fine
    private func request(_ url: URL) async throws -> Data {
        // Make sure we actually have an API key before doing anything

        guard !apiKey.isEmpty else { throw WeatherAPIError.missingKey }
        // Add `appid` (API key) and `units=metric` to the query string

        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var q = comps.queryItems ?? []
        q.append(.init(name: "appid", value: apiKey))
        q.append(.init(name: "units", value: "metric")) // Celsius/metric mode
        comps.queryItems = q
        // Build the final URL we will call

        guard let final = comps.url else { throw WeatherAPIError.badURL }
        print("🌐 Request:", final.absoluteString)
        // Do the actual network call

        let (data, resp) = try await URLSession.shared.data(from: final)
        // Make sure the server replied with HTTP 200
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        if code != 200 {
            // Log the body to help debugging (wrong key, rate limit, etc.)

            let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("❌ HTTP \(code). Body:", body)
            throw WeatherAPIError.network
        }
        return data
    }

    // Fetches the *current* weather for a latitude/longitude.
    // Decodes JSON into our `CurrentWeather` model.
    func currentWeather(lat: Double, lon: Double) async throws -> CurrentWeather {
        // Build the endpoint URL: /data/2.5/weather?lat=...&lon=...

        let url = URL(string: "\(base)/weather?lat=\(lat)&lon=\(lon)")! // ✅ /weather endpoint
        let data = try await request(url)// send network request
        // Convert JSON -> CurrentWeather struct
        return try JSONDecoder().decode(CurrentWeather.self, from: data)
    }

    // Fetches the 5-day / 3-hour *forecast* for a latitude/longitude.
    // Decodes JSON into our `ForecastResponse` model.
    func forecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        // Build the endpoint URL: /data/2.5/forecast?lat=...&lon=...
        let url = URL(string: "\(base)/forecast?lat=\(lat)&lon=\(lon)")!
        let data = try await request(url)// send network request
        // Convert JSON -> ForecastResponse struct
       
        return try JSONDecoder().decode(ForecastResponse.self, from: data)
    }

    // Searches cities by name using OpenWeather's geocoding API.
    // Returns a small list of results with coordinates to use in the calls above.
    func searchCities(_ query: String, limit: Int = 5) async throws -> [GeoResult] {
        // Make the search text safe for URLs (spaces, accents, etc.)

        guard let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return [] }
        // Example: /geo/1.0/direct?q=Toronto&limit=5

        let url = URL(string:"\(geoBase)/direct?q=\(q)&limit=\(limit)")!
        let data = try await request(url) 
        // send network request
        // Convert JSON -> array of GeoResult (name, country, lat/lon)
        return try JSONDecoder().decode([GeoResult].self, from: data)
    }
}
