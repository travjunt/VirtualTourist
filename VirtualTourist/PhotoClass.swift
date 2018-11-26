//
//  PhotoClass.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 12/7/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Photo Class

public class Photo: NSManagedObject {
    convenience init(imageURL: String, imageData: NSData, context: NSManagedObjectContext) {
    
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: entity, insertInto: context)
            self.imageURL = imageURL
            self.imageData = imageData
        } else {
            fatalError("Unable to find Entity name.")
        }
    }
}
