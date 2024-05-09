//
//  BenchmarkViewModel.swift
//  jsonBenchmarking
//
//  Created by Ömer Hamid Kamışlı on 4/27/24.
//

import Foundation
import SwiftUI
import SwiftyJSON
import IkigaJSON
import ObjectMapper
import Foundation

// A class that handles the benchmarking of JSON parsing libraries.
class BenchmarkViewModel: ObservableObject {
    // Holds the benchmark results for each file and library tested.
    @Published var results = [String: [TimeConsumingResult]]()
    // Holds the comparison results for each file.
    @Published var resultsAverage = [String: AverageResult]()
    // Predefined list of file sizes to test.
    var fileNames = ["64KB", "128KB", "256KB", "512KB", "1MB", "5MB"]

    // Initiates the benchmarking process for each file size asynchronously.
    func runBenchmarks() {
        DispatchQueue.global(qos: .userInitiated).async {
            for fileName in self.fileNames {
                self.processBenchmark(for: fileName)
            }
        }
    }
    
    // Processes each file, benchmarking different JSON libraries.
    private func processBenchmark(for fileName: String) {
        guard let jsonData = loadJSONData(from: fileName) else {
            postErrorResult(fileName: fileName, message: "Error loading \(fileName)")
            return
        }
        
        JSONLibraries.allCases.forEach { library in
            self.testLibrary(library, withData: jsonData, forFile: fileName)
        }

        DispatchQueue.main.sync {
            self.compareResults(for: fileName)
        }
    }


    // Runs the benchmark for a given library and updates the results.
    private func testLibrary(_ library: JSONLibraries, withData jsonData: Data, forFile fileName: String) {
        let description = library.description
        let results = benchmarkJSONSerializationToMappingRepeatedly(jsonData: jsonData, iterations: 1000, library: library)
        let result = TimeConsumingResult(framework: library, repetitions: 1000, averageTime: results.average, minTime: results.min, maxTime: results.max, totalTime: results.total, currentMessage: "Completed \(description) Test", isComprasion: false)

        // Update results on the main thread
        DispatchQueue.main.async { [weak self] in
            var currentResults = self?.results[fileName] ?? []
            currentResults.append(result)
            self?.results[fileName] = currentResults
        }
    }


    // Repeatedly benchmarks JSON serialization and mapping, recording performance metrics.
    private func benchmarkJSONSerializationToMappingRepeatedly(jsonData: Data, iterations: Int, library: JSONLibraries) -> (average: Double, max: Double, min: Double, total: Double) {
        var times: [Double] = []
        let dataString = String(decoding: jsonData, as: UTF8.self)
        for _ in 0..<iterations {
            let timeElapsed = timeExecution { self.decodeData(jsonData, asString: dataString, using: library) }
            times.append(timeElapsed)
        }
        
        return calculateStatistics(times)
    }

    // Decodes data using the specified library.
    private func decodeData(_ jsonData: Data, asString dataString: String, using library: JSONLibraries) {
        switch library {
        case .native:
            let decoder = JSONDecoder()
            _ = try? decoder.decode([MockModelCodable].self, from: jsonData)
        case .swiftyJSON:
            _ = try? JSON(data: jsonData).parseTo() as [MockModelCodable]?
        case .ikigaJSON:
            var decoder = IkigaJSONDecoder()
            _ = try? decoder.decode([MockModelCodable].self, from: jsonData)
        case .objectMapper:
            _ = Mapper<MockModelMappable>().mapArray(JSONString: dataString)
        }
    }

    // Calculates statistical metrics for time performance.
    private func calculateStatistics(_ times: [Double]) -> (average: Double, max: Double, min: Double, total: Double) {
        let total = times.reduce(0, +)
        return (total / Double(times.count), times.max()!, times.min()!, total)
    }

    // Measures and returns the elapsed time for a given closure.
    private func timeExecution(_ block: () -> Void) -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()
        block()
        return CFAbsoluteTimeGetCurrent() - startTime
    }

    // Handles the loading of JSON data from a file.
    private func loadJSONData(from fileName: String) -> Data? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("Failed to find the path for \(fileName).json")
            return nil
        }
        return try? Data(contentsOf: URL(fileURLWithPath: path))
    }

    // Posts an error result if JSON data could not be loaded.
    private func postErrorResult(fileName: String, message: String) {
        DispatchQueue.main.async {
            self.results[fileName] = [TimeConsumingResult(framework: .native, repetitions: 0, averageTime: 0, minTime: 0, maxTime: 0, totalTime: 0, currentMessage: message, isComprasion: false)]
        }
    }

    // Compares results across different libraries for a file and stores the best results.
    private func compareResults(for fileName: String) {
        guard let resultsForFile = results[fileName], resultsForFile.count >= 4 else {
            print("Not all tests have completed for \(fileName)")
            return
        }

        let resultsByPerformance = resultsForFile.sorted(by: { $0.averageTime < $1.averageTime })
        let comparisonResult = formComparisonResult(from: resultsByPerformance, for: fileName)
        DispatchQueue.main.async {
            self.resultsAverage[fileName] = comparisonResult
        }
    }

    // Forms the final comparison result from sorted results.
    private func formComparisonResult(from results: [TimeConsumingResult], for fileName: String) -> AverageResult {
        let comparisonMessage = "Comparison for \(fileName):\nAverage Time: \(results[0].framework.description) is fastest"
        return AverageResult(message: comparisonMessage, repetitions: 1000, averageTime: results[0].averageTime, minTime: results[0].minTime, maxTime: results[0].maxTime, totalTime: results[0].totalTime, averageTimeFramework: results[0].framework, minTimeFramework: results[0].framework, maxTimeFramework: results[0].framework, totalTimeFramework: results[0].framework)
    }
}
