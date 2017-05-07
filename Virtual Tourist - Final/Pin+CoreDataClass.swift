//
//  Pin+CoreDataClass.swift
//  Virtual Tourist - Final
//
//  Created by Marc Boanas on 05/05/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

@objc(Pin)
public class Pin: NSManagedObject {
    
    var coordinate: CLLocationCoordinate2D {
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    convenience init(longitude: Double, latitude: Double, pages: Int = 1, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.longitude = longitude
            self.latitude = latitude
            self.pages = UInt32(pages)
            self.creationDate = Date()
        } else {
            fatalError("Unable to find Etity name!")
        }
    }
    
}
