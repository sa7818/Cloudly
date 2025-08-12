//
//  DayRowView.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//


import SwiftUI

// A single row showing one day's summary in the forecast list.
struct DayRowView: View {
    let day: DailySummary // The daily data to display (date, min/max, icon, chance of rain)

    var body: some View {
        HStack {
            // Day label
            Text(Fmt.day.string(from: day.date))
                .frame(width: 140, alignment: .leading)

            Spacer()

            // SF Symbol icon based on the weather code
            Image(systemName: WeatherIcon.symbol(for: day.iconId))
                .frame(width: 30)

            Spacer()

            // Chance of precipitation for the day in %
            Text(Fmt.percent(day.popAvg))
                .frame(width: 60, alignment: .trailing)

            Spacer()

           
            Text("\(Fmt.temp(day.max)) / \(Fmt.temp(day.min))")
                .monospacedDigit()
        }
        // Make the whole row tappable
        .contentShape(Rectangle())
    }
}

// Preview for Xcode canvas

#Preview {
    let sample = DailySummary(
        date: Date(),
        min: 9,
        max: 17,
        iconId: 802,
        popAvg: 0.2,
        entries: []
    )
    DayRowView(day: sample).padding()
}
