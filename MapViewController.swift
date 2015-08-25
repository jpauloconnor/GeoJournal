//
//  MapViewController.swift
//  DatePlaces
//
//  Created by Paul O'Connor on 8/25/15.
//  Copyright (c) 2015 OCApps. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: managedObjectContext, queue: NSOperationQueue.mainQueue()) { notification in
                if self.isViewLoaded() {
                    self.updatePlaces()
                }
            }
        }
    }
    
    
    var places = [Places]()
    
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
        }
    
        @IBAction func showPlaces() {
            let region = regionForAnnotations(places)
            mapView.setRegion(region, animated: true)
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePlaces()
        
        if !places.isEmpty {
            showPlaces()
        }
        
    }
    
    func updatePlaces() {
        let entity = NSEntityDescription.entityForName("Places", inManagedObjectContext: managedObjectContext)
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        
        var error: NSError?
        let foundObjects = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        if foundObjects == nil {
            fatalCoreDataError(error)
            return
        }
        mapView.removeAnnotations(places)
        places = foundObjects as! [Places]
        mapView.addAnnotations(places)
    }
    
    func regionForAnnotations(annotations: [MKAnnotation]) -> MKCoordinateRegion {
        var region: MKCoordinateRegion
        
        switch annotations.count {
            
            //There are no annotations.  Center map on user's position.
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
            
            //Only one annotation.  Center map on the one annotation.
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
        
            //There are two or more annotations.  This has some pretty sweet stuff in it.
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mapView.regionThatFits(region)
    }
    
    func showPlaceDetails(sender: UIButton) {
        performSegueWithIdentifier("EditPlaces", sender: sender)
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditPlaces" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            let button = sender as! UIButton
            let place = places[button.tag]
            controller.placeToEdit = place
        }
    }
}
    extension MapViewController: MKMapViewDelegate {
        func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
            
            //1
            if annotation is Places {
                //2
                let identifier = "Places"
                var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
                if annotationView == nil {
                    annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    //3 - Set some properties to configure the look and feel of the anno view.
                    annotationView.enabled = true
                    annotationView.canShowCallout = true
                    annotationView.animatesDrop = false
                    annotationView.pinColor = .Green
                    
                    //4 - Create a new UIButton/disclosure.  Hook up the touchup.  Add to accessory view.
                    let rightButton = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
                    rightButton.addTarget(self, action: Selector("showPlaceDetails:"), forControlEvents: .TouchUpInside)
                    annotationView.rightCalloutAccessoryView = rightButton
                } else {
                    annotationView.annotation = annotation
                }
                //5 obtain a reference to that detail disclosure button again and set its tag to the index.
                let button = annotationView.rightCalloutAccessoryView as! UIButton
                if let index = find(places, annotation as! Places) {
                    button.tag = index
                }
                
                return annotationView
            }
            
            return nil
        }
}

extension MapViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}



