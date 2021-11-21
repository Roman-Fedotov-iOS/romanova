//
//  PodcastModel.swift
//  romanova
//
//  Created by Roman Fedotov on 28.09.2021.
//

import UIKit

struct PodcastModel: Equatable, Codable {
    var id: Int64
    var duration, commentCount, likeCount: UInt
    var title: String
    var largeArtworkUrl, smallArtworkUrl: String?
    var streamUrl, waveformUrl: String
    var currentPlayTime: Float = 0
    
    static func == (lhs: PodcastModel, rhs: PodcastModel) -> Bool {
            return lhs.id == rhs.id
        }
}
