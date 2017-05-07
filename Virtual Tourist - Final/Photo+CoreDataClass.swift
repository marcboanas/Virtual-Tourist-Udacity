//
//  Photo+CoreDataClass.swift
//  Virtual Tourist - Final
//
//  Created by Marc Boanas on 05/05/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

    convenience init(imageURL: String, imageData: NSData? = nil, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.imageURL = imageURL
            self.imageData = imageData
            self.creationDate = Date()
        } else {
            fatalError("Unable to find Etity name!")
        }
    }
}
