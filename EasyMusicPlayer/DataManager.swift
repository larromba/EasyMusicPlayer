import Foundation

// sourcery: name = DataManger
protocol DataManaging: Mockable {
    func save<T: Keyable, U>(_ data: U?, key: T)
    func load<T: Keyable, U>(key: T) -> U?
}

final class DataManger: DataManaging {
    private let userDefaults: UserDefaultable

    init(userDefaults: UserDefaultable) {
        self.userDefaults = userDefaults
    }

    func save<T: Keyable, U>(_ data: U?, key: T) {
        userDefaults.set(data, forKey: key.rawValue)
    }

    func load<T: Keyable, U>(key: T) -> U? {
        return userDefaults.object(forKey: key.rawValue) as? U
    }
}
