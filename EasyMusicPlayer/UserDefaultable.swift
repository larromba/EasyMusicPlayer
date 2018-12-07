import Foundation

// sourcery: name = UserDefaults
protocol UserDefaultable: Mockable {
    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
}
extension UserDefaults: UserDefaultable {}
