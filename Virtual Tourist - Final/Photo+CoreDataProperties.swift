//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist - Final
//
//  Created by Marc Boanas on 05/05/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var imageURL: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var imageData: NSData?
    @NSManaged public var pin: Pin?

}
