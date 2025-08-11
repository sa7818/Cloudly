//
//  CloudlyApp.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import SwiftUI

@main
struct WeatherCastApp: App {
    @StateObject private var app = AppState()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(app)
        }
    }
}
