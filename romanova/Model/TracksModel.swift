//
//  TracksModel.swift
//  romanova
//
//  Created by Roman Fedotov on 27.08.2021.
//

import UIKit

struct Track: Decodable {
    let kind: String
    let id: Int64
    let comment_count: UInt
    let duration: UInt
    let title: String
    var artwork_url: String
    var large_artwork_url: String? = nil
    var small_artwork_url: String? = nil
    let media: Media
    var waveform_url: String
    let likes_count: UInt
}

struct PlaylistResponse: Decodable {
    let tracks: [Track]
    let title: String
}

struct Media: Decodable {
    let transcodings: [Transcoding]
}

struct Transcoding: Decodable {
    let url: String
    let format: Format
}

struct Format: Decodable {
    let `protocol`: String
}
