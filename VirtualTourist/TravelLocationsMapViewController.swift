//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 11/25/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// MARK: - TravelLocationsMapViewController
class TravelLocationsMapViewController: UIViewController, NSFetchedResultsControllerDelegate {
	
	// MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinsLabel: UILabel!
    
    var pinDropGesture: UILongPressGestureRecognizer!
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStack.sharedInstance().context
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),  NSSortDescriptor(key: "longitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
        self.pinDropGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.dropPin))
		self.mapView.addGestureRecognizer(self.pinDropGesture!)
		
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("Unable to fetch pins.")
        }
        self.mapView.addAnnotations(self.fetchedResultsController.fetchedObjects as! [Pin] as [MKAnnotation])
        self.navigationItem.rightBarButtonItem = self.editButtonItem
	}
    
    @objc func dropPin(sender: UIGestureRecognizer) {
        
        let point = sender.location(in: self.mapView)
        let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
        
        if sender.state == .began {
            
            sharedContext.performAndWait {
                _ = Pin(latitude: coordinate.latitude as Double, longitude: coordinate.longitude as Double, context: self.sharedContext)
                
                do {
                    try CoreDataStack.sharedInstance().saveContext()
                } catch {
                    print("Unable to save context")
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
        }
    }
	
	// Show deletePinsLabel when editing - not working on iPhone X
	override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if editing {
			UIView.animate(withDuration: 0.2, animations: {
				self.mapView.frame.origin.y -= self.deletePinsLabel.frame.height
			})
		} else {
            UIView.animate(withDuration: 0.2, animations: {
                self.mapView.frame.origin.y += self.deletePinsLabel.frame.height
            })
        }
    }
}

// MARK: - Extension TravelLocationsMapViewController

extension TravelLocationsMapViewController: MKMapViewDelegate {
	
	// mapView - viewFor Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.canShowCallout = false
			pinView!.pinTintColor = .red
		} else {
			pinView!.annotation = annotation
		}
		return pinView
	}
	
	// mapView - didSelect
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		
		if isEditing {
			self.sharedContext.delete(findPersistedPin((view.annotation?.coordinate)!)!)
			self.mapView.removeAnnotation(view.annotation!)
			
			do {
				try CoreDataStack.sharedInstance().saveContext()
			} catch {
				print("Error: Unable to save context.")
			}
		} else {
			let controller = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
			
			PhotoAlbumViewController.selectedPin = findPersistedPin((view.annotation?.coordinate)!)
			
			self.navigationController?.pushViewController(controller, animated: true)
			
			mapView.deselectAnnotation(view.annotation, animated: true)
		}
	}
	
	func findPersistedPin(_ coordinate: CLLocationCoordinate2D) -> Pin? {
		
		do {
			try self.fetchedResultsController.performFetch()
		} catch {
			print("Error: Unable to fetch pins.")
		}
		
		let selectedPinLatitude = coordinate.latitude
		let selectedPinLongitude = coordinate.longitude
		
		for fetchedObject in self.fetchedResultsController.fetchedObjects! {
			let pin = fetchedObject as! Pin
			let pinLatitude = pin.latitude
			let pinLongitude = pin.longitude
			
			if selectedPinLatitude == pinLatitude && selectedPinLongitude == pinLongitude {
				return pin
			}
		}
		return nil
	}
}
