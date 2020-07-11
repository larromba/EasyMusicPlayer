import UIKit

protocol SearchCellViewStating {
    var title: String { get }
    var image: UIImage? { get }
    var isImageHidden: Bool { get }
}

struct SearchCellViewState: SearchCellViewStating {
    let title: String
    let image: UIImage?
    var isImageHidden: Bool {
        return image == nil
    }
}
