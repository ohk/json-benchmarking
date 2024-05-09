//
//  MockModel.swift
//  jsonBenchmarking
//
//  Created by Ömer Hamid Kamışlı on 4/27/24.
//

import Foundation
import ObjectMapper

struct MockModelCodable: Codable {
    var name: String?
    var language: String?
    var id: String?
    var bio: String?
    var version: Double?
}

struct MockModelMappable: Mappable {
    var name: String?
    var language: String?
    var id: String?
    var bio: String?
    var version: Double?
    
    init?(map: ObjectMapper.Map) {
    }
    
    mutating func mapping(map: ObjectMapper.Map) {
        name <- map["name"]
        language <- map["language"]
        id <- map["id"]
        bio <- map["bio"]
        version <- map["version"]
    }
}
