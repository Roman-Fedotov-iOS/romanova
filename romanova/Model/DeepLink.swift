//
//  DeepLink.swift
//  romanova
//
//  Created by Roman Fedotov on 13.01.2022.
//

import UIKit

enum DeepLink {
    enum Podcasts {
        case root
        case details(id: String)
    }
    case podcasts(Podcasts)
}

let Deeplinker = DeepLinkManager()
class DeepLinkManager {
   fileprivate init() {}
    private var deepLink: DeepLink?
   // check existing deepling and perform action
    func checkDeepLink() {
       guard var deeplinkType = deepLink else {
          return
       }
     
       DeeplinkNavigator().proceedToDeeplink(deeplinkType)
       // reset deeplink after handling
       self.deepLink = nil // (1)
    }
    @discardableResult
    func handleDeeplink(url: URL) -> Bool {
       deepLink = DeeplinkParser.shared.parseDeepLink(url)!
       return deepLink != nil
    }
}

class DeeplinkNavigator {
   static let shared = DeeplinkNavigator()
   init() { }
   
   func proceedToDeeplink(_ link: DeepLink) {
       switch link {
       case .podcasts(.root):
          print("1")
       case .podcasts(.details(id: let id)):
           if id == "1164740752" {
               print("8")
           }
       }
   }
}

class DeeplinkParser {
   static let shared = DeeplinkParser()
   private init() { }
    
    func parseDeepLink(_ url: URL) -> DeepLink? {
       guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
          return nil
       }
       var pathComponents = components.path.components(separatedBy: "/")
       // the first component is empty
       pathComponents.removeFirst()
       switch host {
       case "podcasts":
          if let podcastId = pathComponents.first {
              return DeepLink.podcasts(.details(id: podcastId))
          }
       default:
          break
       }
       return nil
    }
}
