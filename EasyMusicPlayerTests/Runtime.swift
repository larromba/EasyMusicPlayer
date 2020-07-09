import Foundation
import ObjectiveC

// see https://stackoverflow.com/questions/28479445/convert-objective-c-call-to-swift
func msgSend(target: Any?, action: Selector, object: Any?) {
    let handle: UnsafeMutableRawPointer = dlopen("/usr/lib/libobjc.A.dylib", RTLD_NOW)!
    unsafeBitCast(dlsym(handle, "objc_msgSend"),
                  to: (@convention(c)(Any?, Selector, Any?) -> Void).self)(target, action, object)
    dlclose(handle)
}
// TODO: remove?
