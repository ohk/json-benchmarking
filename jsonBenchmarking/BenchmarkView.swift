//
//  BenchmarkView.swift
//  jsonBenchmarking
//
//  Created by Ömer Hamid Kamışlı on 4/27/24.
//

import SwiftUI

struct BenchmarkView: View {
    @StateObject var viewModel = BenchmarkViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.fileNames, id: \.self) { fileName in
                Section(header: Text(fileName).bold()) {
                    if let resultsForFile = viewModel.results[fileName] {
                        ForEach(resultsForFile, id: \.id) { result in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(result.framework.description).bold()
                                Text("Status: \(result.currentMessage)")
                                if result.repetitions > 0 {
                                    Text("Repetitions: \(result.repetitions)")
                                    Text(String(format: "Average Time: %.8f sec", result.averageTime))
                                    Text(String(format: "Max Time: %.8f sec", result.maxTime))
                                    Text(String(format: "Min Time: %.8f sec", result.minTime))
                                    Text(String(format: "Total Time: %.8f sec", result.totalTime))
                                }
                                
                            }
                            .padding(.vertical, 2)
                            .id(result.id)
                        }
                    } else {
                        Text("Waiting to start...")
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        if let average = viewModel.resultsAverage[fileName] {
                            Text("Result").bold()
                            Text("\(average.message)")
//                            if average.repetitions > 0 {
//                                Text("Repetitions: \(average.repetitions)")
//                                Text(String(format: "Average Time Winner Framework: %@", average.averageTimeFramework.description))
                                Text(String(format: "Average Time: %.8f sec", average.averageTime))
//                                Text(String(format: "Max Time Winner Framework: %@", average.maxTimeFramework.description))
                                Text(String(format: "Max Time: %.8f sec", average.maxTime))
//                                Text(String(format: "Min Time Winner Framework: %@", average.minTimeFramework.description))
                                Text(String(format: "Min Time: %.8f sec", average.minTime))
//                                Text(String(format: "Total Time Winner Framework: %@", average.totalTimeFramework.description))
                                Text(String(format: "Total Time: %.8f sec", average.totalTime))
//                            }
                        } else {
                            Text("Waiting to getting results...")
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.runBenchmarks()
        }
    }
}

struct BenchmarkView_Previews: PreviewProvider {
    static var previews: some View {
        BenchmarkView()
    }
}
