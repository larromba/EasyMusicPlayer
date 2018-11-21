import Foundation

func performAfterDelay(_ delay: Double, closure: @escaping (() -> Void)) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: closure)
}
