//
//  PhotoProperties.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 12/7/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Photo Properties

extension Photo {
	
	@NSManaged public var pin: Pin?
	@NSManaged public var imageURL: String?
	@NSManaged public var imageData: NSData?
	
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }
}
