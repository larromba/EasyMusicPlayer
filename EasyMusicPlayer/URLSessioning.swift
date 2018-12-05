import Foundation

// sourcery: name = URLSession
protocol URLSessioning: Mockable {
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}
extension URLSession: URLSessioning {}
