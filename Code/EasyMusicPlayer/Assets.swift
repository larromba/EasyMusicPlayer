// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Assets {
    internal static let imagePlaceholder = ImageAsset(name: "ImagePlaceholder")
    internal static let nextButton = ImageAsset(name: "NextButton")
    internal static let openSource = ImageAsset(name: "OpenSource")
    internal static let pauseButton = ImageAsset(name: "PauseButton")
    internal static let playButton = ImageAsset(name: "PlayButton")
    internal static let previousButton = ImageAsset(name: "PreviousButton")
    internal static let repeatAllButton = ImageAsset(name: "RepeatAllButton")
    internal static let repeatButton = ImageAsset(name: "RepeatButton")
    internal static let repeatOneButton = ImageAsset(name: "RepeatOneButton")
    internal static let searchButton = ImageAsset(name: "SearchButton")
    internal static let shareButton = ImageAsset(name: "ShareButton")
    internal static let shuffleButton = ImageAsset(name: "ShuffleButton")
    internal static let stopButton = ImageAsset(name: "StopButton")
    internal static let toggle = ImageAsset(name: "Toggle")
  }
  internal enum Colors {
    internal static let controlsBottomRow = ColorAsset(name: "ControlsBottomRow")
    internal static let controlsMiddleRow = ColorAsset(name: "ControlsMiddleRow")
    internal static let controlsTopRow = ColorAsset(name: "ControlsTopRow")
    internal static let infoViewText = ColorAsset(name: "InfoViewText")
    internal static let notFoundText = ColorAsset(name: "NotFoundText")
    internal static let scrubber = ColorAsset(name: "Scrubber")
    internal static let scrubberBackground = ColorAsset(name: "ScrubberBackground")
    internal static let searchProgressView = ColorAsset(name: "SearchProgressView")
    internal static let versionText = ColorAsset(name: "VersionText")
  }
  internal enum PreviewAssets {
    internal static let arkistRendezvousFillYourCoffee = ImageAsset(name: "Arkist-Rendezvous-Fill-Your-Coffee")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
