//
//  WeatherAPI.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import Foundation
import CoreLocation

enum WeatherAPIError : Error { case missingKey, badURL, network, decoding }


final class WeatherAPI: @unchecked Sendable {
    static let shared = WeatherAPI()
    private init(){}
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
    
  
    private let base = "https://api.openweathermap.org/data/2.5"
    private let geoBase = "https://api.openweathermap.org/geo/1.0"
    
   
    private func request(_ url: URL) async throws -> Data {
        guard !apiKey.isEmpty else { throw WeatherAPIError.missingKey }

        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var q = comps.queryItems ?? []
        q.append(.init(name: "appid", value: apiKey))
        q.append(.init(name: "units", value: "metric"))
        comps.queryItems = q

        guard let final = comps.url else { throw WeatherAPIError.badURL }
        print("🌐 Request:", final.absoluteString)

        let (data, resp) = try await URLSession.shared.data(from: final)

        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        if code != 200 {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("❌ HTTP \(code). Body:", body)
            throw WeatherAPIError.network
        }
        return data
    }

    
    func currentWeather(lat: Double, lon: Double) async throws -> CurrentWeather {
        let url = URL(string: "\(base)/weather?lat=\(lat)&lon=\(lon)")!
        let data = try await request(url)
        return try JSONDecoder().decode(CurrentWeather.self, from: data)
    }

   
    func forecast(lat: Double, lon: Double) async throws -> ForecastResponse {
      
        let url = URL(string: "\(base)/forecast?lat=\(lat)&lon=\(lon)")!
        let data = try await request(url)
       
        return try JSONDecoder().decode(ForecastResponse.self, from: data)
    }

   
    func searchCities(_ query: String, limit: Int = 5) async throws -> [GeoResult] {
      
        guard let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return [] }
     
        let url = URL(string:"\(geoBase)/direct?q=\(q)&limit=\(limit)")!
        let data = try await request(url) 
     
        return try JSONDecoder().decode([GeoResult].self, from: data)
    }
}
