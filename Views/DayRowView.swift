//
//  DayRowView.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//


import SwiftUI


struct DayRowView: View {
    let day: DailySummary

    var body: some View {
        HStack {
          
            Text(Fmt.day.string(from: day.date))
                .frame(width: 140, alignment: .leading)

            Spacer()

          
            Image(systemName: WeatherIcon.symbol(for: day.iconId))
                .frame(width: 30)

            Spacer()

          
            Text(Fmt.percent(day.popAvg))
                .frame(width: 60, alignment: .trailing)

            Spacer()

           
            Text("\(Fmt.temp(day.max)) / \(Fmt.temp(day.min))")
                .monospacedDigit()
        }
    
        .contentShape(Rectangle())
    }
}


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
