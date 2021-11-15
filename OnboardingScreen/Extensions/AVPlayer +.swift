//
//  AVPlayer +.swift
//  romanova
//
//  Created by Roman Fedotov on 05.09.2021.
//

import UIKit
import AVKit

extension AVPlayer {
    var isPlaying: Bool {
            return rate != 0 && error == nil
        }
    var playingTimeRemaining: CMTime {
        return self.currentItem!.duration - self.currentTime()
    }
}

