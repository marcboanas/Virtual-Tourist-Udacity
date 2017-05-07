//
//  MapViewController.swift
//  Virtual Tourist - Final
//
//  Created by Marc Boanas on 05/05/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var helpMessage: UIView!
    
    // MARK: Properties
    
    var annotations = [PinAnnotation]()
    
    var lastAnnotation: PinAnnotation?
    
    var context: NSManagedObjectContext = CoreDataManager.sharedInstance().context!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupMap()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addPinToMap))
        
        longPressRecognizer.minimumPressDuration = 0.5
        
        mapView.addGestureRecognizer(longPressRecognizer)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        showOrHideHelpMessage()
    }
    
    // MARK: UILongPressGestureRecognizer
    
    func addPinToMap(gestureRecognizer: UIGestureRecognizer) {
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        
        let coordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        switch gestureRecognizer.state {
            
        case .began:
            
            let annotation = PinAnnotation()
            
            annotation.coordinate = coordinate
            
            lastAnnotation = annotation
            
            mapView.addAnnotation(annotation)
            
        case .changed:
            
            // Allow the pin to be dragged before the user lifts their finger
            
            lastAnnotation?.coordinate = coordinate
            
        case .ended:
            
            let pin = Pin(longitude: coordinate.longitude, latitude: coordinate.latitude, context: context)
            
            CoreDataManager.sharedInstance().saveModel()
            
            // Download photo collection for pin in the background
            
            CoreDataManager.sharedInstance().loadPhotosFromFlickr(pin: pin)
            
            lastAnnotation?.pin = pin
            
            annotations.append(lastAnnotation!)
            
        default:
            
            assert(false, "Unexpected state UIGestureRecognizer type")
            
        }
    }
    
    // Mark: Helper Functions
    
    func setupMap() {
        
        if let mapLocation = UserDefaults.standard.dictionary(forKey: "mapLocation") {
            
            let coordinate = CLLocationCoordinate2D(latitude: mapLocation["latitude"] as! CLLocationDegrees, longitude: mapLocation["longitude"] as! CLLocationDegrees)
            
            let span = MKCoordinateSpanMake(mapLocation["deltaLatitude"] as! CLLocationDegrees, mapLocation["deltaLongitude"] as! CLLocationDegrees)
            
            let region = MKCoordinateRegion(center: coordinate, span: span)
            
            mapView.setRegion(region, animated: true)
        }
        
        let pins: [Pin] = CoreDataManager.sharedInstance().allPins
        
        for pin in pins {
            
            let annotation = PinAnnotation()
            
            annotation.pin = pin
            
            annotation.coordinate = pin.coordinate
            
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    // MARK: IBActions
    
    @IBAction func hideHelpMessage(_ sender: Any) {
    
        UserDefaults.standard.set(false, forKey: "showHelpMessages")
        UserDefaults.standard.synchronize()
        
        showOrHideHelpMessage()
        
    }
    
    func showOrHideHelpMessage() {
        helpMessage.isHidden = !UserDefaults.standard.bool(forKey: "showHelpMessages")
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    // MARK: MKMapViewDelegate Methods
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = mapView.centerCoordinate
        
        let span = mapView.region.span
        
        let locationData = ["latitude": center.latitude, "longitude": center.longitude, "deltaLatitude": span.latitudeDelta, "deltaLongitude": span.longitudeDelta]
        
        UserDefaults.standard.set(locationData, forKey: "mapLocation")
        
        UserDefaults.standard.synchronize()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.animatesDrop = true
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let pin = (view.annotation as! PinAnnotation).pin {
            
            mapView.deselectAnnotation(view.annotation, animated: false)
            
            let nc = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            
            nc.pin = pin
            
            // Change photo album back button to 'Map'
            
            let backButton = UIBarButtonItem(title: "Map", style: .plain, target: nil, action: nil)
            
            navigationItem.backBarButtonItem = backButton
            
            navigationController?.pushViewController(nc, animated: true)
            
        }
        
        mapView.deselectAnnotation(view.annotation, animated: false)
    }
}
