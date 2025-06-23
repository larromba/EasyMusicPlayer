protocol Waitable {
    func waitSync(for duration: Double) async throws
}

extension Waitable {
    func waitSync(for duration: Double = 0.5) async throws {
        let nanoseconds = UInt64(duration * 1_000_000_000)
        try await Task.sleep(nanoseconds: nanoseconds)
    }
}
