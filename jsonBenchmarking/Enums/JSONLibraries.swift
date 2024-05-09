//
//  JSONLibraries.swift
//  jsonBenchmarking
//
//  Created by Ömer Hamid Kamışlı on 4/27/24.
//

import Foundation

enum JSONLibraries: CaseIterable {
    case native
    case swiftyJSON
    case ikigaJSON
    case objectMapper
    
    var description: String {
        switch self {
        case .native:
            return "Native"
        case .swiftyJSON:
            return "SwiftyJSON"
        case .ikigaJSON:
            return "IkigaJSON"
        case .objectMapper:
            return "Object Mapper"
        }
    }
}
