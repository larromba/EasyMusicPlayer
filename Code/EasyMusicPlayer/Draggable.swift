import SwiftUI

protocol Draggable {
    var startLocation: CGPoint { get }
    var velocity: CGSize { get }
    var translation: CGSize { get }
    var predictedEndTranslation: CGSize { get }
}
extension DragGesture.Value: Draggable {}
