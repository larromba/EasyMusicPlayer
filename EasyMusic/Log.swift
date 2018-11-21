import Foundation

func log(_ msg: String) {
    #if DEBUG
    print("ℹ️ \(msg)")
    #endif
}

func log_warning(_ msg: String) {
    #if DEBUG
    print("⚠️ \(msg)")
    #endif
}

func log_error(_ msg: String) {
    #if DEBUG
    print("❌ \(msg)")
    #endif
}
