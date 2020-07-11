import UIKit

protocol SearchCellable {
    var viewState: SearchCellViewStating? { get }
}

final class SearchCell: UITableViewCell, CellIdentifiable {
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var iconImageView: UIImageView!
    private var iconTrailingConstraint: NSLayoutConstraint?

    var viewState: SearchCellViewStating? {
        didSet { _ = viewState.map(bind) }
    }

    // MARK: - private

    private func bind(_ viewState: SearchCellViewStating) {
        guard let titleLabel = titleLabel, let iconImageView = iconImageView else { return }
        titleLabel.text = viewState.title
        iconImageView.image = viewState.image

        tearDownConstraints()
        setUpConstraints(isImageHidden: viewState.isImageHidden)
        layoutIfNeeded()
    }

    private func tearDownConstraints() {
        guard let iconTrailingConstraint = iconTrailingConstraint else { return }
        contentView.removeConstraint(iconTrailingConstraint)
    }

    private func setUpConstraints(isImageHidden: Bool) {
        guard let titleLabel = titleLabel, let iconImageView = iconImageView else { return }
        let constraint: NSLayoutConstraint
        if isImageHidden {
            constraint = NSLayoutConstraint(
                item: iconImageView,
                attribute: .trailing,
                relatedBy: .greaterThanOrEqual,
                toItem: titleLabel,
                attribute: .trailing,
                multiplier: 1,
                constant: 0
            )
        } else {
            constraint = NSLayoutConstraint(
                item: iconImageView,
                attribute: .leading,
                relatedBy: .greaterThanOrEqual,
                toItem: titleLabel,
                attribute: .trailing,
                multiplier: 1,
                constant: 10
            )
        }
        contentView.addConstraint(constraint)
        iconTrailingConstraint = constraint
    }
}
