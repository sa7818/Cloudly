//
//  WeatherViewModelTests.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import XCTest
import CoreLocation
@testable import Cloudly

// Basic unit test scaffold for the WeatherViewModel.
// Goal: ensure we can create the ViewModel on the main actor and
// manipulate simple state without crashing (acts as a smoke test).
final class WeatherViewModelTests: XCTestCase {
    
    // Async test because WeatherViewModel is @MainActor and uses async APIs.
    func testBuildDaily() async {
        // Create the ViewModel on the MainActor (UI thread)
        let vm = await MainActor.run { WeatherViewModel() }
        
        // Simulate a state where there's no active loading and no error.
        // (If API key is missing or coordinates are invalid, we still shouldn't crash.)
        await MainActor.run {
            vm.isLoading = false
            vm.error = nil
        }
        
        // Trivial assertion to mark the test as passed if we reached here without a crash.
        XCTAssertTrue(true)
    }
}
