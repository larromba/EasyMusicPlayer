import UIKit

struct InfoViewState {
    let artist: String?
    let track: String?
    let trackPosition: String?
    let time: String?
    let artwork: UIImage?
}

extension InfoViewState {
    func copy(artist: String?, track: String?, artwork: UIImage?) -> InfoViewState {
        return InfoViewState(
            artist: artist,
            track: track,
            trackPosition: trackPosition,
            time: time,
            artwork: artwork
        )
    }

    func copy(artist: String?, track: String?, trackPosition: String?, artwork: UIImage?) -> InfoViewState {
        return InfoViewState(
            artist: artist,
            track: track,
            trackPosition: trackPosition,
            time: time,
            artwork: artwork
        )
    }

    func copy(time: String?) -> InfoViewState {
        return InfoViewState(
            artist: artist,
            track: track,
            trackPosition: trackPosition,
            time: time,
            artwork: artwork
        )
    }

    func copy(trackPosition: String?) -> InfoViewState {
        return InfoViewState(
            artist: artist,
            track: track,
            trackPosition: trackPosition,
            time: time,
            artwork: artwork
        )
    }
}
