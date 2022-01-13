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
    func isValidEmail()->Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
            return  NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}
