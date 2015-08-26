//
//  Functions.swift
//  DatePlaces
//
//  Created by Paul O'Connor on 8/20/15.
//  Copyright (c) 2015 OCApps. All rights reserved.
//

import Foundation
import Dispatch


//Interesting way to write Void.
func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}

let applicationDocumentsDirectory: String = {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
    return paths[0]
}()
