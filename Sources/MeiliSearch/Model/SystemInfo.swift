import Foundation

/**
 `SystemInfo` instances represent the current System status, this can be used to know the 
 current instance of the MeiliSearch server.
 */
public struct SystemInfo: Codable, Equatable {

    // MARK: Properties

    ///Percentage of memory in use.
    public let memoryUsage: Float

    /// Percentage of CPU core usage, in ascending order.
    public let processorUsage: [Float]

    /// Global data information.
    public let global: Global

    /// System info for the running MeiliSearch server process.
    public let process: Process

    /**
     `Global` instance represent the current data used by the system.
     */
    public struct Global: Codable, Equatable {

        // MARK: Properties

        /// Total of memory available for MeiliSearch server.
        public let totalMemory: Int

        /// Total of used memory MeiliSearch server.
        public let usedMemory: Int

        /// Total of data swap available for MeiliSearch server.
        public let totalSwap: Int

        /// Total of data swap used by MeiliSearch server.
        public let usedSwap: Int

        /// Total of data input to MeiliSearch server.
        public let inputData: Int

        /// Total of data output by MeiliSearch server.
        public let outputData: Int

    }

    /**
     `Process` instance represent the current system capabilities.
     */
    public struct Process: Codable, Equatable {

        // MARK: Properties

        /// Total amount of memory, in kB.
        public let memory: Int

        /// Percentage of CPU usage.
        public let cpu: Int

    }

}
