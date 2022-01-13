//
//  SceneDelegate.swift
//  OnBoardingScreen
//
//  Created by Roman Fedotov on 21.08.2021.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        var controller: UIViewController!
        
        if UserDefaults.standard.hasOnboarded == true {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            controller = storyboard.instantiateViewController(identifier: "MethodsVC")
        } else {
            controller = OnboardingViewController.instantiate()
        }
        
        if UserDefaults.standard.string(forKey: "authMethod") != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            controller = storyboard.instantiateViewController(identifier: "MainVC")
        }
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    internal func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
           
        let url = URLContexts.first!.url as NSURL

        if url == NSURL(string: "romanova://podcasts/1164740752") {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = (storyboard.instantiateViewController(identifier: "PlayerVC")) as! PlayerViewController
            controller.podcastModel = PodcastModel(id: 1164740752, duration: 1238779, likeCount: 0, title: "Уникальный экземпляр #8", largeArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", smallArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", streamUrl: "https://api-v2.soundcloud.com/media/soundcloud:tracks:1164740752/74c86cd3-fe76-4eb7-bb26-45e45bea63b1/stream/hls", waveformUrl: "https://wave.sndcdn.com/Tt1fKgDRUc9s_m.png", currentPlayTime: 0)
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.window?.rootViewController?.present(controller, animated: true, completion: nil)
        } else if url == NSURL(string: "romanova://podcasts/1164740665") {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = (storyboard.instantiateViewController(identifier: "PlayerVC")) as! PlayerViewController
            controller.podcastModel = PodcastModel(id: 1164740665, duration: 1306410, likeCount: 0, title: "Уникальный экземпляр #7", largeArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", smallArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", streamUrl: "https://api-v2.soundcloud.com/media/soundcloud:tracks:1164740470/9c3499d4-e207-47ed-ba0e-2b2137b88dd2/stream/hls", waveformUrl: "https://wave.sndcdn.com/JVjGNFircNVI_m.png", currentPlayTime: 0)
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.window?.rootViewController?.present(controller, animated: true, completion: nil)
        } else if url == NSURL(string: "romanova://podcasts/1164740638") {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = (storyboard.instantiateViewController(identifier: "PlayerVC")) as! PlayerViewController
            controller.podcastModel = PodcastModel(id: 1164740638, duration: 1665907, likeCount: 0, title: "Уникальный экземпляр #6", largeArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", smallArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", streamUrl: "https://api-v2.soundcloud.com/media/soundcloud:tracks:1164740638/9a8eea18-85fb-4fa5-aebb-f9bc175febc4/stream/hls", waveformUrl: "https://wave.sndcdn.com/uZjo4wDVtE1C_m.png", currentPlayTime: 0)
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.window?.rootViewController?.present(controller, animated: true, completion: nil)
        } else if url == NSURL(string: "romanova://podcasts/1164740575") {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = (storyboard.instantiateViewController(identifier: "PlayerVC")) as! PlayerViewController
            controller.podcastModel = PodcastModel(id: 1164740575, duration: 757238, likeCount: 0, title: "Уникальный экземпляр #5", largeArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", smallArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", streamUrl: "https://api-v2.soundcloud.com/media/soundcloud:tracks:1164740575/55f8abd4-23ac-4598-b56e-dda1d65fa521/stream/hls", waveformUrl: "https://wave.sndcdn.com/Ikm971KGlX03_m.png", currentPlayTime: 0)
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.window?.rootViewController?.present(controller, animated: true, completion: nil)
        } else if url == NSURL(string: "romanova://podcasts/1164740530") {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = (storyboard.instantiateViewController(identifier: "PlayerVC")) as! PlayerViewController
            controller.podcastModel = PodcastModel(id: 1164740530, duration: 1045420, likeCount: 0, title: "Уникальный экземпляр #4", largeArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", smallArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", streamUrl: "https://api-v2.soundcloud.com/media/soundcloud:tracks:1164740530/f16ac7d9-a46d-4b05-a0bc-b9c2dc50ea74/stream/hls", waveformUrl: "https://wave.sndcdn.com/9CB8C2Hsdj4H_m.png", currentPlayTime: 0)
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.window?.rootViewController?.present(controller, animated: true, completion: nil)
        } else if url == NSURL(string: "romanova://podcasts/1164740509") {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = (storyboard.instantiateViewController(identifier: "PlayerVC")) as! PlayerViewController
            controller.podcastModel = PodcastModel(id: 1164740509, duration: 1591092, likeCount: 0, title: "Уникальный экземпляр #3", largeArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", smallArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", streamUrl: "https://api-v2.soundcloud.com/media/soundcloud:tracks:1164740509/40843b4a-15b1-437f-bbc3-92309dce73d8/stream/hls", waveformUrl: "https://wave.sndcdn.com/N2dVzXhW6PjM_m.png", currentPlayTime: 0)
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.window?.rootViewController?.present(controller, animated: true, completion: nil)
        } else if url == NSURL(string: "romanova://podcasts/1164740485") {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = (storyboard.instantiateViewController(identifier: "PlayerVC")) as! PlayerViewController
            controller.podcastModel = PodcastModel(id: 1164740485, duration: 1702034, likeCount: 0, title: "Уникальный экземпляр #2", largeArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", smallArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", streamUrl: "https://api-v2.soundcloud.com/media/soundcloud:tracks:1164740485/130edf37-3fa8-4fed-84f7-4c97834b8242/stream/hls", waveformUrl: "https://wave.sndcdn.com/l63wAlxTMXk2_m.png", currentPlayTime: 0)
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.window?.rootViewController?.present(controller, animated: true, completion: nil)
        } else if url == NSURL(string: "romanova://podcasts/1164740470") {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = (storyboard.instantiateViewController(identifier: "PlayerVC")) as! PlayerViewController
            controller.podcastModel = PodcastModel(id: 1164740470, duration: 965590, likeCount: 0, title: "Уникальный экземпляр #1", largeArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", smallArtworkUrl: "https://i1.sndcdn.com/artworks-JfAE7fLFq0yllEpn-2VNnyw-large.jpg", streamUrl: "https://api-v2.soundcloud.com/media/soundcloud:tracks:1164740470/9c3499d4-e207-47ed-ba0e-2b2137b88dd2/stream/hls", waveformUrl: "https://wave.sndcdn.com/JVjGNFircNVI_m.png", currentPlayTime: 0)
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.window?.rootViewController?.present(controller, animated: true, completion: nil)
        }
    }
}

