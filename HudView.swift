//
//  HudView.swift
//  DatePlaces
//
//  Created by Paul O'Connor on 8/20/15.
//  Copyright (c) 2015 OCApps. All rights reserved.
//

import UIKit

class HudView: UIView {

    var text = ""
    
    class func hudInView(view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.opaque = false
        view.addSubview(hudView)
        view.userInteractionEnabled = false
       
        return hudView
        
    }

    override func drawRect(rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        //Draws a box for the checkmark.  It's a grey box in the center of the screen. 
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height - boxHeight) / 2), width: boxWidth, height: boxHeight)
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        //Loads the checkmark inot a UIImage object.  Then, calculates the position based on center coord of HUD view and dimensions of image.
        if let image = UIImage(named: "Checkmark") {
            
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2), y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.drawAtPoint(imagePoint)
            
            //A dictionary with key value pairs that says how big the text is and colors used for font and foreground.
            let attribs = [ NSFontAttributeName: UIFont.systemFontOfSize(16.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
            
            
            let textSize = text.sizeWithAttributes(attribs)
            //Calculate how wide and tall the text will be.
            let textPoint = CGPoint(x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4)
            
            text.drawAtPoint(textPoint, withAttributes: attribs)
          
        }
        
    }
    
    func showAnimated(animated: Bool) {
        
    }
}
