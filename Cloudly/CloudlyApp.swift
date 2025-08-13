//
//  CloudlyApp.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import SwiftUI

@main
struct WeatherCastApp: App {
    //Declares the main app entry point and injects the shared AppState as an @StateObject into the environment.
    @StateObject private var app = AppState()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(app)
        }
    }
}
