//
//  SwiftyCodable.swift
//  jsonBenchmarking
//
//  Created by Ömer Hamid Kamışlı on 5/8/24.
//

import Foundation
import SwiftyJSON

extension JSON {
    func parseTo<T: Codable>() -> T? {
        guard let data = try? rawData(options: .prettyPrinted) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
}
