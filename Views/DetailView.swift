//
//  DetailView.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//


import SwiftUI
import Charts


struct DetailView: View {
    let day: DailySummary
    let current: CurrentWeather?

    var body: some View {
        ZStack {
          
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.53, green: 0.81, blue: 0.98),
                    Color(red: 0.69, green: 0.93, blue: 0.93)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

         
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                  
                    Text(Fmt.day.string(from: day.date))
                        .font(.title)
                        .bold()

                   
                    let ref = day.entries.first
                    metricGrid(ref)

                  
                    if !day.entries.isEmpty {
                        Text("Hourly").font(.headline)
                 
                        Chart(day.entries, id: \.id) { e in
                            let d = Date(timeIntervalSince1970: e.dt)
                           
                            LineMark(
                                x: .value("Time", Fmt.hour.string(from: d)),
                                y: .value("Temp (°C)", e.main.temp)
                            )
                            .foregroundStyle(.black)
                          
                            PointMark(
                                x: .value("Time", Fmt.hour.string(from: d)),
                                y: .value("Temp (°C)", e.main.temp)
                            )
                        }
                        .frame(height: 220)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    
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
