//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 12/7/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MapKit

// MARK: - PhotoAlbumViewController

class PhotoAlbumViewController: UIViewController {
	
	// MARK: - IBOutlets
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
	@IBOutlet weak var bottomButton: UIBarButtonItem!

	
	// MARK: - IBActions
	@IBAction func bottomButtonPressed(_ sender: Any) {
		if selectedIndexPaths.isEmpty {
			refreshPhotos()
		} else {
			deleteSelectedPhotos()
		}
	}
	
    static var selectedPin: Pin? = nil
	
	var selectedIndexPaths = [IndexPath]()
	var insertedIndexPaths: [IndexPath]!
	var deletedIndexPaths: [IndexPath]!
	
	lazy var sharedContext: NSManagedObjectContext = {
		return CoreDataStack.sharedInstance().context
	}()
	
	lazy var fetchedResultsController: NSFetchedResultsController = { () ->
		NSFetchedResultsController<NSFetchRequestResult> in
		
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pin", ascending: true),  NSSortDescriptor(key: "imageURL", ascending: true)]
		fetchRequest.predicate = NSPredicate(format: "pin == %@", PhotoAlbumViewController.selectedPin!)
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		
		return fetchedResultsController
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		centerMapOnLocation((PhotoAlbumViewController.selectedPin?.coordinate)!)
		
		let annotation = MKPointAnnotation()
		annotation.coordinate = (PhotoAlbumViewController.selectedPin?.coordinate)!
		self.mapView.addAnnotation(annotation)
		
		setCollectionFlowLayout()
		configureBottomButton()
		
		collectionView.allowsMultipleSelection = true
		
		do {
			try self.fetchedResultsController.performFetch()
		} catch {
			print("Unable to fetch photos.")
		}
		
		if let fetchedPhotos = self.fetchedResultsController.fetchedObjects, fetchedPhotos.count == 0 {
			
			downloadImageURLs()
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: nil) { _ in
		self.setCollectionFlowLayout()
		}
	}
	
	let regionRadius: CLLocationDistance = 500
	func centerMapOnLocation (_ coordinate: CLLocationCoordinate2D) {
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
		self.mapView.setRegion(coordinateRegion, animated: true)
	}
	
	func setCollectionFlowLayout() {
		let space: CGFloat = 3.0
		let dimension = (view.frame.size.width - (2 * space)) / 3.0
	
		flowLayout.minimumInteritemSpacing = space
		flowLayout.minimumLineSpacing = space
		flowLayout.itemSize = CGSize(width: dimension, height: dimension)
	}
	
	func downloadImageURLs() {
		FlickrClient.sharedInstance().GETPhotos() { (imageURLArray, error) in
			if let error = error {
				Alerts.pushAlert(controller: self, message: error.localizedDescription)
			} else {
				if let imageURLArray = imageURLArray as? [String] {
					
					for imageURL in imageURLArray {
						
						self.sharedContext.performAndWait {
							let image = Photo(context: self.sharedContext)
							image.imageURL = imageURL
							image.pin = PhotoAlbumViewController.selectedPin
							
							do {
								try CoreDataStack.sharedInstance().saveContext()
							} catch {
								print("Unable to save context.")
							}
						}
					}
				}
				self.sharedContext.performAndWait {
					do {
						try self.fetchedResultsController.performFetch()
					} catch {
						print("Unable to fetch photos.")
					}
					self.collectionView.reloadData()
				}
			}
		}
	}
	
	func downloadImageData(_ photo: Photo, completionHandlerForSaveImageData: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
		
		if let imageURL = URL(string: photo.imageURL!) {
			
			DispatchQueue.global(qos: .background).async {
				if let imageData = try? Data(contentsOf: imageURL) {
					
					self.sharedContext.performAndWait {
						photo.imageData = imageData as NSData
						
						do {
							try CoreDataStack.sharedInstance().saveContext()
						} catch {
							print("Unable to save context.")
						}
						
						completionHandlerForSaveImageData(true, nil)
					}
					
				} else {
					
					self.sharedContext.performAndWait {
						completionHandlerForSaveImageData(false, "Unable to download image from URL: \(imageURL)")
					}
				}
			}
		}
	}
	
	func configureBottomButton() {
		if selectedIndexPaths.isEmpty {
			bottomButton.title = "New Collection"
		} else {
			bottomButton.title = "Delete"
		}
	}
	
	func refreshPhotos() {
		if let fetchedPhotos = self.fetchedResultsController.fetchedObjects {
			for photo in fetchedPhotos {
				self.sharedContext.delete(photo as! NSManagedObject)
			}
			
			self.sharedContext.performAndWait {
				do {
					try CoreDataStack.sharedInstance().saveContext()
				} catch {
					print("Unable to save context.")
				}
			}
		}
		
		downloadImageURLs()
	}
	
	func deleteSelectedPhotos() {
		for indexPath in selectedIndexPaths {
			if let fetchedPhotos = self.fetchedResultsController.fetchedObjects {
				self.sharedContext.delete(fetchedPhotos[(indexPath as NSIndexPath).item] as! NSManagedObject)
				
				self.sharedContext.performAndWait {
					do {
						try CoreDataStack.sharedInstance().saveContext()
					} catch {
						print("Unable to save context.")
					}
				}
			}
		}
		selectedIndexPaths = [IndexPath]()
		configureBottomButton()
	}
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	// number of sections
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.fetchedResultsController.sections?.count ?? 0
	}
	
	// collectionView - numberOfItemsInSection
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.fetchedResultsController.sections![section].numberOfObjects
	}
	
	// collectionView - cellForItemAt
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
		
		cell.activityIndicator.startAnimating()
		cell.imageView.image = UIImage(named: "CellPlaceholder")
		
		if let fetchedPhotos = self.fetchedResultsController.fetchedObjects, fetchedPhotos.count > 0 {
			let photoObject = fetchedPhotos[(indexPath as NSIndexPath).item] as! Photo
			
			if let imageData = photoObject.imageData {
				
				cell.imageView.image = UIImage(data: imageData as Data)
				cell.activityIndicator.stopAnimating()
			} else {
				if photoObject.imageURL != nil {
					
					downloadImageData(photoObject) { (success, errorString) in
						
						if success {
							
							do {
								try self.fetchedResultsController.performFetch()
							} catch {
								print("Unable to fetch photos")
							}
							
							performUIUpdatesOnMain {
								self.collectionView.reloadData()
							}
						} else {
							print(errorString!)
						}
					}
				}
			}
		}
		return cell
	}
	
	// collectionView - didSelectItemAt
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedIndexPaths.append(indexPath)
		configureBottomButton()
	}
	
	// collectionView - didDeselectItemAt
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		if let indexToRemove = selectedIndexPaths.index(of: indexPath) {
			selectedIndexPaths.remove(at: indexToRemove)
		}
		configureBottomButton()
	}
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		self.insertedIndexPaths = [IndexPath]()
		self.deletedIndexPaths = [IndexPath]()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		
		switch type {
		case .insert:
			self.insertedIndexPaths.append(newIndexPath!)
			break
		case .delete:
			self.deletedIndexPaths.append(indexPath!)
			break
		default:
			break
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		
		self.collectionView.performBatchUpdates({ () -> Void in
			
			for indexPath in self.insertedIndexPaths {
				self.collectionView.insertItems(at: [indexPath])
			}
			
			for indexPath in self.deletedIndexPaths {
				self.collectionView.deleteItems(at: [indexPath])
			}
		}, completion: nil)
	}
}
