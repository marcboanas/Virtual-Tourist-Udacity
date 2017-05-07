//
//  FlickrConstants.swift
//  Virtual Tourist - Final
//
//  Created by Marc Boanas on 05/05/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct Constants {
        
        struct Flickr {
            static let ApiScheme: String = "https"
            static let ApiHost: String = "api.flickr.com"
            static let ApiPath: String = "/services/rest/"
            static let SearchBBoxHalfWidth: Double = 1.0
            static let SearchBBoxHalfHeight: Double = 1.0
            static let SearchLatRange: (Double, Double) = (-90.0, 90.0)
            static let SearchLongRange: (Double, Double) = (-180, 180)
        }
        
        // MARK: Flickr Parameter Keys
        
        struct FlickrParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let GalleryID = "gallery_id"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let SafeSearch = "safe_search"
            static let Text = "text"
            static let BoundingBox = "bbox"
            static let Page = "page"
            static let PerPage = "per_page"
        }
        
        // MARK: Flickr Parameter Values
        
        struct FlickrParameterValues {
            static let SearchMethod = "flickr.photos.search"
            static let APIKey = "697bce321710a89f7025e33bac8251fe"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1" /* 1 means "yes" */
            static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
            static let GalleryID = "5704-72157622566655097"
            static let MediumURL = "url_m"
            static let UseSafeSearch = "1"
            static let PhotosPerPage = "9"
        }
        
        // MARK: Flickr Response Keys
        
        struct FlickrResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let Title = "title"
            static let MediumURL = "url_m"
            static let Pages = "pages"
            static let Total = "total"
        }
        
        // MARK: Flickr Response Values
        
        struct FlickrResponseValues {
            static let OKStatus = "ok"
        }
        
    }
}
