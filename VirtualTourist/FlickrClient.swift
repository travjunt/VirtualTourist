//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 12/7/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import Foundation

// MARK: - Flickr Client

class FlickrClient: NSObject {
	
	var photoURLArray = [URL]()

	class func sharedInstance() -> FlickrClient {
		struct Singleton {
			static var sharedInstance = FlickrClient()
		}
		return Singleton.sharedInstance
	}
	
	// MARK: - GET Method
	
	func taskForGETMethod(_ methodParameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
		
		let session = URLSession.shared
		let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func pushError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            // Guard - Check for Error
            guard (error == nil) else {
                pushError((error?.localizedDescription)!)
                return
            }
            // Guard - Check for successful response code
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                pushError("Your request returned a status code other than 2xx.")
                return
            }
            // Guard - Check for data
            guard let data = data else {
                pushError("No data was returned by the request")
                return
            }
            
            self.convertDataWithCompletionHandler(data) { (result, error) in
                
                if let error = error {
                    completionHandlerForGET(nil, error)
                } else {
					
                    guard let stat = result?[ResponseKeys.Status] as? String, stat == ResponseValues.OKStatus else {
						pushError("Flickr returned an error: \(String(describing: result))")
                        return
                    }
					
                    guard let photosDictionary = result?[ResponseKeys.Photos] as? [String : AnyObject] else {
                        pushError("Cannot find keys \(ResponseKeys.Photos)' in \(String(describing: result))")
                        return
                    }
                    completionHandlerForGET(photosDictionary as AnyObject, nil)
                }
            }
        }
        task.resume()
        return task
    }
    
    private func flickrURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
    
    func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
}
