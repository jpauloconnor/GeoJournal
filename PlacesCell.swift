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
    @IBOutlet weak var photoImageView: UIImageView!
    
    func configureForLocation(place: Places) {
        if place.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
    } else {
        descriptionLabel.text = place.locationDescription
        }
        if let placemark = place.placemark {
            var text = ""
            text.addText(placemark.subThoroughfare)
            text.addText(placemark.thoroughfare, withSeparator: ", ")
            text.addText(placemark.locality, withSeparator: ", ")
            addressLabel.text = text
        } else {
            addressLabel.text = String(format:
                "Lat: %.8f, Long: %.8f", place.latitude, place.longitude)
        }
        photoImageView.image = imageForPlace(place)
    }
    //This function returns the image from the Place or an empty placeholder image.
    func imageForPlace(place: Places) -> UIImage {
        if place.hasPhoto {
            if let image = place.photoImage {
                return image.resizedImageWithBounds(CGSize(width: 52, height: 52))
            }
        }
        return UIImage()
    }
}
