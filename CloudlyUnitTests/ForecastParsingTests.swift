//
//  ForecastParsingTests.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import XCTest
@testable import Cloudly

final class ForecastParsingTests: XCTestCase {
    
  
    func testDecodeForecast() throws {
        let json = """
        { "list": [], "city": { "name":"Test","country":"CA","timezone":0 } }
        """.data(using: .utf8)!
        
        let decoded = try JSONDecoder().decode(ForecastResponse.self, from: json)
        
        XCTAssertEqual(decoded.city.name, "Test")
    }
}
