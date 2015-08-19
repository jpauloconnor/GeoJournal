//
//  FirstViewController.swift
//  DatePlaces
//
//  Created by Paul O'Connor on 8/18/15.
//  Copyright (c) 2015 OCApps. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
        //Has to be an optional because it is possible to not have a location.
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func getLocation(sender: AnyObject) {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .Denied || authStatus == .Restricted {
                showLocationServicesDeniedAlert()
                return
            }
        startLocationManager()
        updateLabels()
    }
    
    // MARK: -CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Hey this failed with a big ole error \(error)")
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let newLocation = locations.last as! CLLocation
        println("didUpdateLocations \(newLocation)")
        lastLocationError = nil
        location = newLocation
        updateLabels()
        
    }
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messageLabel.text = ""
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.hidden = true
            
            var statusMessage: String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain &&
                    error.code == CLError.Denied.rawValue{
                        statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = "Tap 'Get My Location' to Start"
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        updatingLocation = true
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }

}

