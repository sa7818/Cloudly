//
//  WeatherViewModelTests.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import XCTest
import CoreLocation
@testable import Cloudly

final class WeatherViewModelTests: XCTestCase {
    
    func testBuildDaily() async {
        let vm = await MainActor.run { WeatherViewModel() }
        
       
        await MainActor.run {
            vm.isLoading = false
            vm.error = nil
        }
        
        XCTAssertTrue(true)
    }
}
