//
//  WeatherViewModel.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//
import Foundation
import CoreLocation

// ViewModel = connects the UI to the data (network + models).
// Runs on the main actor because it updates @Published properties used by SwiftUI.
@MainActor
final class WeatherViewModel: ObservableObject {
    // UI state flags and data the views will observe

    @Published var isLoading = false  // show/hide loading state
    @Published var error: String? // user-friendly error message
    @Published var current: CurrentWeather? // "right now" weather details
    @Published var days: [DailySummary] = [] // daily summaries for the list

    // Cache the raw 3-hourly forecast entries we fetched last time (used for details)
    private var forecastEntries : [ForecastResponse.Entry] = []
    
    // Main entry point: load weather for a given coordinate (latitude/longitude).
    // Uses concurrency to fetch "current" and "forecast" at the same time.
  
    func load(for coordinate: CLLocationCoordinate2D) async {
        isLoading = true; error = nil
        do{
            // Fire two network calls in parallel

          
            async let currentTask = WeatherAPI.shared.currentWeather(lat: coordinate.latitude, lon: coordinate.longitude)
            async let forecastTask = WeatherAPI.shared.forecast(lat:coordinate.latitude, lon:coordinate.longitude)
            
            // Wait for both to finish

            let (cw,fr) = try await (currentTask, forecastTask)
            
            // Update published properties for the UI

            self.current = cw
            self.forecastEntries = fr.list
            self.days = Self.buildDaily(from: fr.list) // group 3-hour entries into days
            isLoading = false
        } catch {
            // If a previous request was canceled (e.g., user picked a new city), ignore
            let ns = error as NSError
            if ns.domain == NSURLErrorDomain && ns.code == NSURLErrorCancelled {
                return // a newer request started; not an error
            }
            // Log and set a simple error message for the UI
            print("❌ Weather API error:", error)
            self.error = (error as? WeatherAPIError == .missingKey) ? "Missing API key." : "Failed to load weather."
            isLoading = false
        }

    }
    // Helper for Detail screen: return the hourly entries that belong to a given day.
    func hours(for day: DailySummary) -> [ForecastResponse.Entry]{
        day.entries
    }
    
    // Take all 3-hour forecast entries and convert them into one summary per calendar day:
    // - find min/max temps
    // - choose a "dominant" weather code (for the day's icon)
    // - average the POP (chance of precipitation)
    // - keep the original entries for hourly charts/details
    private static func buildDaily(from entries : [ForecastResponse.Entry]) -> [DailySummary]{
        let calendar = Calendar.current
        // Group by each entry's day (local calendar)
        let grouped = Dictionary(grouping: entries) { e in
            Date(timeIntervalSince1970: e.dt).startOfDay(calendar: calendar)
        }
        // Turn each group into a DailySummary, sorted by date

        let summaries = grouped.keys.sorted().map { day -> DailySummary in
            let items = grouped[day]!.sorted { $0.dt < $1.dt}
            // Compute min/max across the day's entries

            let min = items.map{$0.main.temp_min}.min() ?? 0
            let maxTemp = items.map { $0.main.temp_max }.max() ?? 0
            // Pick a representative icon by the most frequent weather code
            let icon = Self.dominantWeatherCode(in: items)
            // Average POP (probability of precipitation). If POP is missing, it's ignored by compactMap.
            let pop = items.compactMap { $0.pop }.reduce(0, +) / Double(Swift.max(items.count, 1))
            // Build the daily view model
            return DailySummary(date: day, min: min, max: maxTemp, iconId: icon, popAvg: pop, entries: items)

            
        }
        // Limit to the next 7 days (UI-friendly)
        return Array(summaries.prefix(7))
    }
    // Find the most common weather code among the day's entries.
    // This acts as the "dominant" condition for choosing an icon.
   
    private static func dominantWeatherCode(in items: [ForecastResponse.Entry]) -> Int {
        let codes = items.flatMap{$0.weather}.map{$0.id}
        return codes.reduce(into:[:]){$0[$1, default: 0] += 1}.max(by:{$0.value < $1.value})?.key ?? 800
        
    }
}

// Small helper to get the start of a day using a specific calendar.
// Keeps date arithmetic consistent and readable.
private extension Date {
    func startOfDay(calendar: Calendar) -> Date {calendar.startOfDay(for: self)}
}
