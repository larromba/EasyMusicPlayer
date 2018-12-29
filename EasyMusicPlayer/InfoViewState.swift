import UIKit

protocol InfoViewStating {
    var artist: String? { get }
    var track: String? { get }
    var trackPosition: String? { get }
    var time: String? { get }
    var artwork: UIImage? { get }

    func copy(artist: String?, track: String?, artwork: UIImage?) -> InfoViewStating
    func copy(artist: String?, track: String?, trackPosition: String?, artwork: UIImage?) -> InfoViewStating
    func copy(time: String?) -> InfoViewStating
    func copy(trackPosition: String?) -> InfoViewStating
}

struct InfoViewState: InfoViewStating {
    let artist: String?
    let track: String?
    let trackPosition: String?
    let time: String?
    let artwork: UIImage?
}

extension InfoViewState {
    func copy(artist: String?, track: String?, artwork: UIImage?) -> InfoViewStating {
        return InfoViewState(
            artist: artist,
            track: track,
            trackPosition: trackPosition,
            time: time,
            artwork: artwork
        )
    }

    func copy(artist: String?, track: String?, trackPosition: String?, artwork: UIImage?) -> InfoViewStating {
        return InfoViewState(
            artist: artist,
            track: track,
            trackPosition: trackPosition,
            time: time,
            artwork: artwork
        )
    }

    func copy(time: String?) -> InfoViewStating {
        return InfoViewState(
            artist: artist,
            track: track,
            trackPosition: trackPosition,
            time: time,
            artwork: artwork
        )
    }

    func copy(trackPosition: String?) -> InfoViewStating {
        return InfoViewState(
            artist: artist,
            track: track,
            trackPosition: trackPosition,
            time: time,
            artwork: artwork
        )
    }
}
