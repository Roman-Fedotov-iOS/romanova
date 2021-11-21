//
//  UserDefaults+.swift
//  romanova
//
//  Created by Roman Fedotov on 27.08.2021.
//

import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String {
        case hasOnboarded
        case hasSignedIn
    }
    var hasOnboarded: Bool {
        get {
            bool(forKey: UserDefaultsKeys.hasOnboarded.rawValue)
        }
        set {
            setValue(newValue, forKey: UserDefaultsKeys.hasOnboarded.rawValue)
        }
    }
    var hasSignedIn: Bool {
        get {
            bool(forKey: UserDefaultsKeys.hasSignedIn.rawValue)
        }
        set {
            setValue(newValue, forKey: UserDefaultsKeys.hasSignedIn.rawValue)
        }
    }
}
