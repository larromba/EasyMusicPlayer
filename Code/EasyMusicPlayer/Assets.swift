// swiftlint:disable all
import SwiftUI

public actor Asset {
  public actor Assets {
  }
  public actor Colors {
    public static let accentColor = ColorAsset(name: "AccentColor")
    public static let controlsBottomRow = ColorAsset(name: "ControlsBottomRow")
    public static let controlsMiddleRow = ColorAsset(name: "ControlsMiddleRow")
    public static let controlsTopRow = ColorAsset(name: "ControlsTopRow")
    public static let infoViewText = ColorAsset(name: "InfoViewText")
    public static let notFoundText = ColorAsset(name: "NotFoundText")
    public static let scrubber = ColorAsset(name: "Scrubber")
    public static let scrubberBackground = ColorAsset(name: "ScrubberBackground")
    public static let searchProgressView = ColorAsset(name: "SearchProgressView")
    public static let versionText = ColorAsset(name: "VersionText")
  }
  public actor PreviewAssets {
  }
}

public struct ColorAsset {
  fileprivate let name: String

  public var color: Color {
    Color(self)
  }
}

public extension Color {
  init(_ asset: ColorAsset) {
    self.init(asset.name, bundle: Bundle.main)
  }
}

// swiftlint:enable all