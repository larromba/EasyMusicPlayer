import Foundation

protocol Authorizable {
    var isAuthorized: Bool { get }

    func authorize(_ completion: @escaping ((_ success: Bool) -> Void))
}
