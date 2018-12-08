import Foundation

// sourcery: name = Authorization
protocol Authorization: Mockable {
    var isAuthorized: Bool { get }

    func authorize(_ completion: @escaping ((_ success: Bool) -> Void))
}
