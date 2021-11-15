//
//  Duration.swift
//  romanova
//
//  Created by Roman Fedotov on 19.09.2021.
//

import Foundation

struct Duration {
    
    let seconds: UInt
    let minutes: UInt
    let hours: UInt
    
    func toString(isTimeInverted: Bool) -> String {
        
        var resultString = ""
        if self.hours != 0 {
            resultString += String(self.hours) + ":"
        }
        
        switch (hours, minutes) {
        case (0,0) :
            resultString += "00" + ":"
            
        case (let h, let m) where h == 0 && m != 0 :
            resultString += String(self.minutes) + ":"
            
        case (let h, _) where h != 0 :
            resultString +=  String(String(String(self.minutes).reversed()).padding(toLength: 2, withPad: "0", startingAt: 0).reversed()) + ":"
        default:
            break
        }
        resultString +=  String(String(String(self.seconds).reversed()).padding(toLength: 2, withPad: "0", startingAt: 0).reversed())
        if isTimeInverted {
            return  "-\(resultString)"
        } else {
            return  resultString
        }
    }
}
