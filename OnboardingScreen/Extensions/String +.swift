//
//  String +.swift
//  romanova
//
//  Created by Roman Fedotov on 26.08.2021.
//

import Foundation

extension String {
    var asURL: URL? {
        return URL(string: self)
    }
}
