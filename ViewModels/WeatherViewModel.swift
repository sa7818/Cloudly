//
//  WeatherViewModel.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//
import Foundation
import CoreLocation


@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var current: CurrentWeather?
    @Published var days: [DailySummary] = []

    
    private var forecastEntries : [ForecastResponse.Entry] = []
    
   
  
    func load(for coordinate: CLLocationCoordinate2D) async {
        isLoading = true; error = nil
        do{
          
            async let currentTask = WeatherAPI.shared.currentWeather(lat: coordinate.latitude, lon: coordinate.longitude)
            async let forecastTask = WeatherAPI.shared.forecast(lat:coordinate.latitude, lon:coordinate.longitude)
            
         
            let (cw,fr) = try await (currentTask, forecastTask)
            
          
            self.current = cw
            self.forecastEntries = fr.list
            self.days = Self.buildDaily(from: fr.list)
            isLoading = false
        } catch {
           
            let ns = error as NSError
            if ns.domain == NSURLErrorDomain && ns.code == NSURLErrorCancelled {
                return
            }
           
            print("❌ Weather API error:", error)
            self.error = (error as? WeatherAPIError == .missingKey) ? "Missing API key." : "Failed to load weather."
            isLoading = false
        }

    }
    
    func hours(for day: DailySummary) -> [ForecastResponse.Entry]{
        day.entries
    }
    
  
    private static func buildDaily(from entries : [ForecastResponse.Entry]) -> [DailySummary]{
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: entries) { e in
            Date(timeIntervalSince1970: e.dt).startOfDay(calendar: calendar)
        }
        
        let summaries = grouped.keys.sorted().map { day -> DailySummary in
            let items = grouped[day]!.sorted { $0.dt < $1.dt}
            
            let min = items.map{$0.main.temp_min}.min() ?? 0
            let maxTemp = items.map { $0.main.temp_max }.max() ?? 0
            
            let icon = Self.dominantWeatherCode(in: items)
            
            let pop = items.compactMap { $0.pop }.reduce(0, +) / Double(Swift.max(items.count, 1))
            
            return DailySummary(date: day, min: min, max: maxTemp, iconId: icon, popAvg: pop, entries: items)

            
        }
        return Array(summaries.prefix(7))
    }
    
   
    private static func dominantWeatherCode(in items: [ForecastResponse.Entry]) -> Int {
        let codes = items.flatMap{$0.weather}.map{$0.id}
        return codes.reduce(into:[:]){$0[$1, default: 0] += 1}.max(by:{$0.value < $1.value})?.key ?? 800
        
    }
}


private extension Date {
    func startOfDay(calendar: Calendar) -> Date {calendar.startOfDay(for: self)}
}
