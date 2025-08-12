//
//  ForecastParsingTests.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import XCTest
@testable import Cloudly
// Simple unit test to make sure our ForecastResponse model
// can decode basic JSON from the forecast API.
final class ForecastParsingTests: XCTestCase {
    
    // This test builds a tiny JSON string that looks like what the API returns:
    // - "list" is an empty array (no forecast entries)
    // - "city" has minimal fields: name/country/timezone
    // Then it decodes that JSON into ForecastResponse and checks the city name.
    func testDecodeForecast() throws {
        let json = """
        { "list": [], "city": { "name":"Test","country":"CA","timezone":0 } }
        """.data(using: .utf8)!
        // Try to decode using Swift's JSONDecoder and our Decodable model

        let decoded = try JSONDecoder().decode(ForecastResponse.self, from: json)
        // Verify that decoding worked and the city name matches what we put in the JSON
        XCTAssertEqual(decoded.city.name, "Test")
    }
}
