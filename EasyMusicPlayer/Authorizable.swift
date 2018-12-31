import Foundation

// sourcery: name = Authorization
protocol Authorization: Mockable {
    // sourcery: value = true
    var isAuthorized: Bool { get }

    func authorize(_ completion: @escaping ((_ success: Bool) -> Void))
}
