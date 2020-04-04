import Foundation

public struct SystemInfo: Codable, Equatable {
    let memoryUsage: Float
    let processorUsage: [Float]
    let global: Global
    let process: Process

    struct Global: Codable, Equatable {
        let totalMemory: Int
        let usedMemory: Int
        let totalSwap: Int
        let usedSwap: Int
        let inputData: Int
        let outputData: Int
    }

    struct Process: Codable, Equatable {
        let memory: Int
        let cpu: Int
    }

}