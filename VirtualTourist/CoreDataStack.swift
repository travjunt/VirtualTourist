//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 12/7/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Core Data Stack

struct CoreDataStack {
	
	// Declare Properties
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let databaseURL: URL
    let context: NSManagedObjectContext
	
    init?(modelName: String) {
        
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName) in the main bundle")
            return nil
        }
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
        let fileManager = FileManager.default
        
        guard let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach the documents folder")
            return nil
        }
        
        self.databaseURL = docURL.appendingPathComponent("model.sqlite")
        
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("Unable to add store at \(databaseURL)")
        }
    }
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options: [NSObject : AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseURL, options: nil)
    }
	
	static func sharedInstance() -> CoreDataStack {
		struct Singleton {
			static var sharedInstance = CoreDataStack(modelName: "VirtualTourist")
		}
		return Singleton.sharedInstance!
	}
	
}

// MARK: - Save Data

extension CoreDataStack {
	
	func saveContext() throws {
		if context.hasChanges {
			try context.save()
		}
	}
}

// MARK: - Delete Saved Data

internal extension CoreDataStack {
    
    func dropAllData() throws {
        try coordinator.destroyPersistentStore(at: databaseURL, ofType: NSSQLiteStoreType, options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseURL, options: nil)
    }
}
