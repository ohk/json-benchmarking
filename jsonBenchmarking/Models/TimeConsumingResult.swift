//
//  TimeConsumingResult.swift
//  jsonBenchmarking
//
//  Created by Ömer Hamid Kamışlı on 4/27/24.
//

import Foundation

struct TimeConsumingResult {
    var framework: JSONLibraries
    var repetitions: Int
    var averageTime: Double
    var minTime: Double
    var maxTime: Double
    var totalTime: Double
    var currentMessage: String
    var isComprasion: Bool
    
    var id: String {
        return framework.description + currentMessage + "\(repetitions) - \(averageTime) - \(totalTime)"
    }
}
