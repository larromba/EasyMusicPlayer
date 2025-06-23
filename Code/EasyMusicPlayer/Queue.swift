import Foundation

/// @mockable
protocol Queue: AnyObject {
    var maxConcurrentOperationCount: Int { get set }

    func addOperation(_ op: Operation)
    func addOperation(_ block: @escaping @Sendable () -> Void)
    func cancelAllOperations()
}
extension OperationQueue: Queue {}
