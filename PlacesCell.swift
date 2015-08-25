//
//  PlacesCell.swift
//  DatePlaces
//
//  Created by Paul O'Connor on 8/24/15.
//  Copyright (c) 2015 OCApps. All rights reserved.
//

import UIKit

class PlacesCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    func configureForLocation(place: Places) {
        if place.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
    } else {
        descriptionLabel.text = place.locationDescription
        }
        if let placemark = place.placemark { addressLabel.text =
            "\(placemark.subThoroughfare) \(placemark.thoroughfare)," +
            "\(placemark.locality)" } else {
            addressLabel.text = String(format:
            "Lat: %.8f, Long: %.8f", place.latitude, place.longitude)
        }
    }
}
