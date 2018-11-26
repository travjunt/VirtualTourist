//
//  PinClass.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 12/7/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import Foundation
import CoreData
import MapKit

// MARK: - Pin Class

public class Pin: NSManagedObject, MKAnnotation {
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity name.")
        }
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude as Double, longitude: self.longitude as Double)
    }
}
