import Foundation

public struct SystemInfo: Codable, Equatable {
    public let memoryUsage: Float
    public let processorUsage: [Float]
    public let global: Global
    public let process: Process

    public struct Global: Codable, Equatable {
        public let totalMemory: Int
        public let usedMemory: Int
        public let totalSwap: Int
        public let usedSwap: Int
        public let inputData: Int
        public let outputData: Int
    }

    public struct Process: Codable, Equatable {
        public let memory: Int
        public let cpu: Int
    }

}
