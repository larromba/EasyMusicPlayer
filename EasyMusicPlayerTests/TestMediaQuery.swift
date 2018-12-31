import Foundation
import MediaPlayer

final class TestMediaQuery: MPMediaQuery {
    private var _items: [MPMediaItem]
    override var items: [MPMediaItem]? {
        guard
            let predicate = self.filterPredicates?.first as? MPMediaPropertyPredicate,
            let id = predicate.value as? MPMediaEntityPersistentID,
            let item = _items.first(where: { $0.persistentID == id }) else { return _items }
        return [item]
    }

    init(items: [MPMediaItem]) {
        _items = items
        super.init(filterPredicates: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
