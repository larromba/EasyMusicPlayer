import SwiftUI

protocol DragGestureValue {
    var startLocation: CGPoint { get }
    var velocity: CGSize { get }
    var translation: CGSize { get }
    var predictedEndTranslation: CGSize { get }
}
extension DragGesture.Value: DragGestureValue {}
