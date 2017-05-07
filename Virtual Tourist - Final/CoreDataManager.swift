//
//  CoreDataManager.swift
//  Virtual Tourist - Final
//
//  Created by Marc Boanas on 05/05/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import CoreData
import CoreLocation

class CoreDataManager: NSObject {

    let context = CoreDataStack(modelName: "Model")?.context

    var allPins: [Pin] = []
    
    override init() {
        
        super.init()
        
        fetchPins()
    }
    
    func fetchPins() {
        
        do {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            
            let pins = try context?.fetch(fetchRequest) as! [Pin]
        
            allPins = pins
            
        } catch {
            
            print("Error: Could not fetch pins.")
            
        }
    }
    
    func loadPhotosFromFlickr(pin: Pin) {
        
        FlickrClient.sharedInstace().getPhotosByLatAndLong(latitude: pin.latitude, longitude: pin.longitude, pages: "\(pin.pages)") { (photosDictionary, errorString) in
            
            guard errorString == nil else {
                
                print(errorString!)
                
                return
            }
            
            guard let photosDictionary = photosDictionary else {
                
                print("No photos dictionary returned from Flickr")
                
                return
            }
            
            DispatchQueue.main.async {
                
                pin.pages = photosDictionary[FlickrClient.Constants.FlickrResponseKeys.Pages] as! UInt32
            
                let photoArray = photosDictionary[FlickrClient.Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]]
                
                for photo in photoArray! {
                    
                    let url = photo[FlickrClient.Constants.FlickrResponseKeys.MediumURL] as! String
                    
                    let photo = Photo(imageURL: url, context: self.context!)
                    
                    photo.pin = pin
                }
                
                self.saveModel()
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "photosAddedToPin"), object: nil, userInfo: ["pinObjectID": pin.objectID])
                
            }
            
        }
    }
    
    // MARK: Save Model
    
    func saveModel() {
        
        context?.perform {
            
            do {
                
                try self.context?.save()
                
            } catch {
                
                print("Error: Could not save context")
                
            }
        }
    }

    // MARK: Shared Instance
    
    class func sharedInstance() -> CoreDataManager {
        
        struct Singleton {
            
            static var sharedInstace = CoreDataManager()
            
        }
        
        return Singleton.sharedInstace
    }

}


