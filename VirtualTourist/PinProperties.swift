//
//  PinProperties.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 12/7/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Pin Properties

extension Pin {
	
	@NSManaged public var latitude: Double
	@NSManaged public var longitude: Double
	@NSManaged public var photos: NSSet?
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }
}

extension Pin {
	
	@objc(addPhotos:)
	@NSManaged public func addToPhotos(_ values: NSSet)
	
    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)
	
	@objc(removePhotos:)
	@NSManaged public func removeFromPhotos(_ values: NSSet)
	
    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)
}
