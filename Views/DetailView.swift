//
//  DetailView.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

/** What it does:
       -  Shows detailed daily forecast: Wind Speed, Humidity, Pressure, Visibility.
       -  Includes a Swift Charts graph for hourly temperatures.*/

import SwiftUI
import Charts


// Screen that shows details for a single day:
// - Key metrics (humidity, pressure, wind, visibility)
// - An hourly temperature chart for that day

struct DetailView: View {
    let day: DailySummary // The selected day's summary (min/max, entries, etc.)
    let current: CurrentWeather? // "Right now" weather

    var body: some View {
        ZStack {
            // Sky blue gradient background (fills entire screen)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.53, green: 0.81, blue: 0.98), // light sky blue
                    Color(red: 0.69, green: 0.93, blue: 0.93) // lighter cyan
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Content scrolls if it gets taller than the screen
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Big day title, e.g. "Tue, Aug 8"
                    Text(Fmt.day.string(from: day.date))
                        .font(.title)
                        .bold()
                    // Use the first 3-hour entry from this day as our "reference" for metrics
                    // (If it's missing, we fall back to `current` where possible)
                    let ref = day.entries.first
                    metricGrid(ref)

                    // Hourly temperature chart (only if we have entries for this day)
                    if !day.entries.isEmpty {
                        Text("Hourly").font(.headline)
                        // Charts: plot one point per forecast entry (every ~3 hours)
                        //Chart maps each entry: X = hour, Y = temperature, then draws LineMark + PointMark.
                        Chart(day.entries, id: \.id) { e in
                            let d = Date(timeIntervalSince1970: e.dt)
                            // Draw a line connecting temperature points over the day
                            LineMark(
                                x: .value("Time", Fmt.hour.string(from: d)),  // ← X axis is the hour label
                                y: .value("Temp (°C)", e.main.temp)  // ← Y axis is the temperature value
                            )
                            .interpolationMethod(.catmullRom) // The line curves smoothly between points, making the chart look more natural.
                            .foregroundStyle(.black)
                            // Draw a dot at each hourly point
                            PointMark(
                                x: .value("Time", Fmt.hour.string(from: d)),
                                y: .value("Temp (°C)", e.main.temp)
                            )
                            .foregroundStyle(.black)
                        }
                        .frame(height: 220) // Chart height
                        //Make axes/grid black
                        .chartXAxis {
                                AxisMarks { value in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(.black)
                                    AxisTick()
                                        .foregroundStyle(.black)
                                    AxisValueLabel()
                                        .foregroundStyle(.black)
                                }
                            }
                        .chartYAxis {
                                AxisMarks { value in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(.black)
                                    AxisTick()
                                        .foregroundStyle(.black)
                                    AxisValueLabel()
                                        .foregroundStyle(.black)
                                }
                            }
                    }
                }
                .padding() // Outer padding for the content
            }
        }
        // Standard inline navigation title for this screen
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Builds a 2x2 grid of metric cards (Humidity, Pressure, Wind, Visibility)
    // We prefer values from the day's first entry; if not available, fall back to `current`.
    @ViewBuilder
    private func metricGrid(_ e: ForecastResponse.Entry?) -> some View {
        let humidity = e?.main.humidity ?? Double(Int(current?.main.humidity ?? 0))
        let pressure = e?.main.pressure ?? (current?.main.pressure ?? 0)
        let wind = e?.wind.speed ?? (current?.wind.speed ?? 0)
        let visibility = (e?.visibility ?? current?.visibility ?? 0) / 1000.0 // meters → km

        Grid(horizontalSpacing: 16, verticalSpacing: 12) {
            GridRow {
                metric("Humidity", "\(humidity)%")
                metric("Pressure", String(format: "%.0f hPa", pressure))
            }
            GridRow {
                metric("Wind", String(format: "%.1f m/s", wind))
                metric("Visibility", String(format: "%.1f km", visibility))
            }
        }
    }
    // One metric card: small title + big value, styled as a rounded tile.
    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3).bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial) 
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
