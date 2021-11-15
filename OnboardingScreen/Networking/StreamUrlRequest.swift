//
//  StreamURLRequest.swift
//  romanova
//
//  Created by Roman Fedotov on 25.09.2021.
//

import Foundation

@objc class StreamUrlRequest: NSObject {
    
    let completionHandler: (Result<StreamUrlResponse, Error>) -> Void
    
    var session: URLSession?
    
    init(completionHandler: @escaping (Result<StreamUrlResponse, Error>) -> Void) {
        
        self.completionHandler = completionHandler
        
        super.init()
        
        let sessionConfig: URLSessionConfiguration = URLSessionConfiguration.default
        
        self.session = URLSession(configuration: sessionConfig)
    }
    
    func getStreamUrl(streamUrl: String, retryCount: Int = 20) {
        
        let request = NSMutableURLRequest(url: NSURL(string: streamUrl)! as URL,
                                          
                                          cachePolicy: .useProtocolCachePolicy,
                                          
                                          timeoutInterval: 10.0)
        
        request.setValue("application/json, text/javascript, */*; q=0.01", forHTTPHeaderField: "Accept")
        request.setValue("api-v2.soundcloud.com", forHTTPHeaderField: "Host")
        request.setValue("OAuth 2-290059-1022167099-oo1b6zAMBiOGi", forHTTPHeaderField: "Authorization")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.httpMethod = "GET"
        
        let sessionConfig: URLSessionConfiguration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfig)
        
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                
                if let error = error {
                    if retryCount > 0 {
                        self.getStreamUrl(streamUrl: streamUrl, retryCount: retryCount - 1)
                    }
                    print("Some error")
                    self.completionHandler(.failure(error))
                    return
                }
                
                guard let data = data, let httpResponse = response as? HTTPURLResponse, error == nil else {
                    print("No valid response")
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(StreamUrlResponse.self, from: data)
                    self.completionHandler(.success(response))
                    
                } catch let jsonError {
                    if retryCount > 0 {
                        self.getStreamUrl(streamUrl: streamUrl, retryCount: retryCount - 1)
                    }
                    print("Status code was \(httpResponse.statusCode), but expected 2xx")
                    self.completionHandler(.failure(jsonError))
                }
            }
        }
        .resume()
    }
    
}
