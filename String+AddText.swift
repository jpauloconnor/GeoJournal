//
//  String+AddText.swift
//  DatePlaces
//
//  Created by Paul O'Connor on 8/26/15.
//  Copyright (c) 2015 OCApps. All rights reserved.
//

import Foundation
extension String {
    mutating func addText(text: String?, withSeparator separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
