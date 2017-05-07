//
//  PhotoAlbumViewController.swift
//  Virtual Tourist - Final
//
//  Created by Marc Boanas on 05/05/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import UIKit
import MapKit
import CoreData

private let reuseIdentifier = "PhotoCell"

class PhotoAlbumViewController: CoreDataCollectionViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var removeButton: UIBarButtonItem!
    
    // MARK: Properties
    
    var pin: Pin? = nil
    
    var mapView: MKMapView!
    
    var selectedPhotos: [Photo] = []
    
    var footerIndexPath: IndexPath!
    
    var newCollectionButton: UIButton!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collectionView?.allowsMultipleSelection = true
        
        setFetchedResultController()
        
        setupLayout()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //if fetchedResultsController?.fetchedObjects?.count == 0 {
            
        if (pin?.photos?.count)! == 0 {
            
            newCollectionButtonLoading()

            getNewCollection()
            
        } else {

            newCollectionButton.isEnabled = true
            
        }
        
    }
    
    func setFetchedResultController() {
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        
        fr.predicate = NSPredicate(format: "pin = %@", argumentArray: [pin!])
        
        fr.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: CoreDataManager.sharedInstance().context!, sectionNameKeyPath: nil, cacheName: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNewCollectionButton(_:)), name: Notification.Name(rawValue: "photosAddedToPin"), object: nil)
    }
    
    func setupLayout() {
        
        let space: CGFloat = 3.0
        
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        
        flowLayout.minimumLineSpacing = space
        
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func setupHeaderMap() {
        
        if let coordinate = pin?.coordinate {
            
            let span = MKCoordinateSpanMake(0.1, 0.1)
            
            let region = MKCoordinateRegion(center: coordinate, span: span)
            
            mapView.setRegion(region, animated: false)
            
            let annotation = PinAnnotation()
            
            annotation.coordinate = coordinate
            
            mapView.addAnnotation(annotation)
        }
    }
    
    func updateNewCollectionButton(_ notification: Notification) {
        
        let pinObjectID = notification.userInfo?["pinObjectID"] as! NSManagedObjectID
        
        let pinObject = CoreDataManager.sharedInstance().context?.object(with: pinObjectID) as! Pin
        
        let noPhotos = (pinObject.photos?.count) == 0
        
        if pinObject == pin {
            
            newCollectionButton.isEnabled = !noPhotos
            
            newCollectionButton.setTitle("New collection", for: .normal)
            
            newCollectionButton.setTitle("No photos to display!", for: .disabled)
            
        }
        
    }
    
    func newCollectionButtonLoading() {
        
        newCollectionButton.isEnabled = false
        
        newCollectionButton.setTitle("Loading...", for: .disabled)
        
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
    
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        
        cell.imageView.image = nil
        
        cell.contentView.contentMode = .scaleAspectFill
        
        if let imageData = photo.imageData {
            
            cell.imageView.image = UIImage(data: imageData as Data)
            
            cell.activityIndicator.stopAnimating()
            
        } else {
        
            let url = URL(string: photo.imageURL!)
            
            let session = URLSession.shared
            
            let request = URLRequest(url: url!)
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { (imageData, response, error) in
                
                DispatchQueue.main.async {
                    
                    if error == nil {
                        
                        photo.imageData = imageData as NSData?
                        
                        CoreDataManager.sharedInstance().saveModel()
                        
                    } else {
                        
                        print("Error downloading imageData: \(error!.localizedDescription)")
                        
                    }
                    
                }
                
            })
            
            task.resume()
            
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PhotoAlbumHeader", for: indexPath) as! PhotoAlbumHeader
            
            mapView = header.mapView
            
            setupHeaderMap()
            
            return header
            
        case UICollectionElementKindSectionFooter:
            
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PhotoAlbumFooter", for: indexPath) as! PhotoAlbumFooter
            
            newCollectionButton = footer.newCollectionButton
            
            return footer
            
        default:
            
            assert(false, "Unexpected element kind")
        }
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let photo = fetchedResultsController?.object(at: indexPath) as? Photo {
        
            selectedPhotos.append(photo)
        
        }
        
        removeButton.isEnabled = selectedPhotos.count > 0 ? true : false
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let photo = fetchedResultsController?.object(at: indexPath) as? Photo {
        
            selectedPhotos.remove(at: selectedPhotos.index(of: photo)!)
        
        }
        
        removeButton.isEnabled = selectedPhotos.count > 0 ? true : false
    }
    
    @IBAction func deleteSelectedPhotos(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        
        selectedPhotos.removeAll()
        
    }
    
    // MARK: IBActions

    @IBAction func removePhotos(_ sender: Any) {
        
        // If all photos are removed then we automatically get a new collection of photos for the user
        
        if (pin?.photos?.count)! == selectedPhotos.count {
            
            getNewCollection()
            
        }
        
        for photo in selectedPhotos {
            
            CoreDataManager.sharedInstance().context?.delete(photo)
            
        }
        
        CoreDataManager.sharedInstance().saveModel()
        
        selectedPhotos.removeAll()
        
    }
    
    @IBAction func newCollection(_ sender: Any) {
        
        newCollectionButtonLoading()
        
        removeAllPhotos()
        
        getNewCollection()
        
    }
    
    private func removeAllPhotos() {
        
        for photo in (fetchedResultsController?.fetchedObjects)! {
            
            CoreDataManager.sharedInstance().context?.delete(photo as! NSManagedObject)
            
        }
        
    }
    
    private func getNewCollection() {
        
        CoreDataManager.sharedInstance().loadPhotosFromFlickr(pin: pin!)
        
        CoreDataManager.sharedInstance().saveModel()
        
        newCollectionButtonLoading()
        
    }
    
}
