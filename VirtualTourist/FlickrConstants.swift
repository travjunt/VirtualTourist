//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 12/7/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import Foundation

    // MARK: - Flickr Constants

extension FlickrClient {
	
	struct Flickr {
		static let APIScheme = "https"
		static let APIHost = "api.flickr.com"
		static let APIPath = "/services/rest"
		
		static let SearchBBoxHalfWidth = 1.0
		static let SearchBBoxHalfHeight = 1.0
		static let SearchLatRange = (-90.0, 90.0)
		static let SearchLonRange = (-180.0, 180.0)
	}
	
	// MARK: - Flickr Parameter Keys
	struct ParameterKeys {
		static let Method = "method"
		static let APIKey = "api_key"
		static let Extras = "extras"
		static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PhotosPerPage = "per_page"
	}
	
	// MARK: - Flickr Parameter Values
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "78fc2e24e6715809c5779c0712f6fb18"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PhotosPerPage = "21"
    }
	
	// MARK: - Flickr Response Keys
    struct ResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
	
	// MARK: - Flickr Response Values
    struct ResponseValues {
        static let OKStatus = "ok"
    }
}
