import Foundation

// sourcery: name = DataManger
protocol DataManaging: Mockable {
    func save<T: Keyable, U>(_ data: U?, key: T)
    func load<T: Keyable, U>(key: T) -> U?
}

final class DataManger: DataManaging {
    private let database: UserDefaultable

    init(database: UserDefaultable) {
        self.database = database
    }

    func save<T: Keyable, U>(_ data: U?, key: T) {
        database.set(data, forKey: key.rawValue)
    }

    func load<T: Keyable, U>(key: T) -> U? {
        return database.object(forKey: key.rawValue) as? U
    }
}
