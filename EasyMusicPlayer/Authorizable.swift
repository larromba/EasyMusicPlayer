import Foundation

// sourcery: name = Authorizer
protocol Authorizable: Mockable {
    var isAuthorized: Bool { get }

    func authorize(_ completion: @escaping ((_ success: Bool) -> Void))
}
