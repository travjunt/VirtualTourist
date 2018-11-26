//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 12/7/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import Foundation

// MARK: - Flickr Convenience

extension FlickrClient {
	
	// Method Parameters
    static let methodParameters: [String : AnyObject] = [
        ParameterKeys.Method: ParameterValues.SearchMethod as AnyObject,
        ParameterKeys.APIKey: ParameterValues.APIKey as AnyObject,
        ParameterKeys.SafeSearch: ParameterValues.UseSafeSearch as AnyObject,
        ParameterKeys.Extras: ParameterValues.MediumURL as AnyObject,
        ParameterKeys.Format: ParameterValues.ResponseFormat as AnyObject,
        ParameterKeys.NoJSONCallback: ParameterValues.DisableJSONCallback as AnyObject,
        ParameterKeys.PhotosPerPage: ParameterValues.PhotosPerPage as AnyObject
    ]
	
	static func bboxString() -> String {
		
		if let latitude = PhotoAlbumViewController.selectedPin?.latitude, let longitude = PhotoAlbumViewController.selectedPin?.longitude {
			
			let maximumLon = max(longitude - Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.0)
			let maximumLat = max(latitude - Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.0)
			let minimumLon = min(longitude + Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.0)
			let minimumLat = min(latitude + Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.0)
			
			return "\(minimumLon), \(minimumLat), \(maximumLon), \(maximumLat)"
		} else {
			return "0,0,0,0"
		}
	}
	
	// MARK: - GET Convenience Methods
	
    func GETPhotos(_ methodParameters: [String : AnyObject] = methodParameters, completionHandlerForGETPhotos: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var methodParametersWithBBoxString = methodParameters
        
        CoreDataStack.sharedInstance().context.performAndWait {
            methodParametersWithBBoxString[ParameterKeys.BoundingBox] = FlickrClient.bboxString() as AnyObject
        }
        
        let _ = self.taskForGETMethod(methodParametersWithBBoxString) { (photosDictionary, error) in
            
            if let error = error {
                completionHandlerForGETPhotos(nil, error)
            } else {
                if let totalPages = photosDictionary?[ResponseKeys.Pages] as? Int, totalPages > 0 {
                    
                    let pageLimit = min(totalPages, 190)
                    let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                    self.GETPhotos(methodParametersWithBBoxString, withPageNumber: randomPage, completionHandlerForGETPhotos: completionHandlerForGETPhotos)
                } else {
                    completionHandlerForGETPhotos(nil, NSError(domain: "GETPhotos parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse GETPhotos"]))
                }
            }
        }
    }
    
    func GETPhotos(_ methodParameters: [String : AnyObject] = methodParameters, withPageNumber: Int, completionHandlerForGETPhotos: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[ParameterKeys.Page] = withPageNumber as AnyObject?
        
        CoreDataStack.sharedInstance().context.performAndWait {
            methodParametersWithPageNumber[ParameterKeys.BoundingBox] = FlickrClient.bboxString() as AnyObject
        }
        
        let _ = self.taskForGETMethod(methodParametersWithPageNumber) { (photosDictionary, error) in
            
            if let error = error {
                completionHandlerForGETPhotos(nil, error)
            } else {
                if let photosArray = photosDictionary?[ResponseKeys.Photo] as? [[String : AnyObject]], photosArray.count > 0 {
                    var imageURLArray = [String]()
                    
                    for photo in photosArray {
                        if let imageURLString = photo[FlickrClient.ResponseKeys.MediumURL] as? String {
                            imageURLArray.append(imageURLString)
                        }
                    }
                    completionHandlerForGETPhotos(imageURLArray as AnyObject, nil)
                }
            }
        }
    }
}
