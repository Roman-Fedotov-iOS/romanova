//
//  RequestFunc.swift
//  romanova
//
//  Created by Roman Fedotov on 27.08.2021.
//

import UIKit

class NetworkService {
    let urlString = "https://api-v2.soundcloud.com/users/1025550217/tracks?\(clientId)"
    
    func getTracks(urlString: String, completion: @escaping (Result<PlaylistResponse, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        
        request.setValue("application/json, text/javascript, */*; q=0.01", forHTTPHeaderField: "Accept")
        request.setValue("api-v2.soundcloud.com", forHTTPHeaderField: "Host")
        request.setValue("OAuth 2-290059-1022167099-oo1b6zAMBiOGi", forHTTPHeaderField: "Authorization")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                if let error = error {
                    print("Some error")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data, let httpResponse = response as? HTTPURLResponse, error == nil else {
                    print("No valid response")
                    return
                }

                do {
                    let tracks = try JSONDecoder().decode(PlaylistResponse.self, from: data)
                    let tracks1 = tracks.collection.map { Track1 -> Track in
                        var _Track1 = Track1
                        _Track1.small_artwork_url = Track1.artwork_url?.replacingOccurrences(of: "large", with: "t200x200")
                        _Track1.large_artwork_url = Track1.artwork_url?.replacingOccurrences(of: "large", with: "t500x500")
                        _Track1.waveform_url = Track1.waveform_url?.replacingOccurrences(of: "json", with: "png")
                        return _Track1
                    }
                    
                    completion(.success(PlaylistResponse(collection: tracks1)))
                    
                } catch let jsonError {
                    print("Status code was \(httpResponse.statusCode), but expected 2xx")
                    completion(.failure(jsonError))
                }
            }
        }
        .resume()
    }
}
