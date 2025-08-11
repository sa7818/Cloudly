//
//  Formatters.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//

import Foundation


enum Fmt {
    
   
    static let day : DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d"
        return df
    }()
    
 
    static let hour : DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "ha"
        return df
    }()
    
  
    static func temp(_ c : Double) -> String {
        String(format:"%.0f", c)
    }
    
  
    static func percent(_ p : Double) -> String {
        String(format:"%.0f%%", p*100)
    }
}
