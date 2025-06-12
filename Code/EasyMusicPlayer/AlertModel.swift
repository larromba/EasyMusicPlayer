import Foundation

struct AlertModel {
    let title: String
    let text: String
    let buttonTitle: String
    var isPresented = true
}

extension AlertModel {
    static let empty = AlertModel(title: "", text: "", buttonTitle: "", isPresented: false)
}
