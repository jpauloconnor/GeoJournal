//
//  Places.swift
//  
//
//  Created by Paul O'Connor on 8/21/15.
//
//

import Foundation
import CoreData
import CoreLocation

class Places: NSManagedObject {

    @NSManaged var attribute: Double
    @NSManaged var longitude: Double
    @NSManaged var date: NSDate
    @NSManaged var locationDescription: String
    @NSManaged var category: String
    @NSManaged var placemark: CLPlacemark?

}
