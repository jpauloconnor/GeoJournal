//
//  LocationDetailsViewController.swift
//  DatePlaces
//
//  Created by Paul O'Connor on 8/19/15.
//  Copyright (c) 2015 OCApps. All rights reserved.
//

import UIKit
import CoreLocation
import Dispatch
import CoreData

private let dateFormatter: NSDateFormatter = {
   let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
    
}()

class LocationDetailsViewController: UITableViewController {
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var descriptionText = ""
    var categoryName = "No Category"
    var managedObjectContext: NSManagedObjectContext!
    var date = NSDate()
    var image: UIImage?
    var observer: AnyObject!
    
    
    var placeToEdit: Places? {
        //didSet block will be performed whenever you put a new value into the variable.
        
        didSet {
            if let place = placeToEdit {
                descriptionText = place.locationDescription
                categoryName = place.category
                date = place.date
                coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude)
                placemark = place.placemark
                println("2")
                
            }
        }
    }
    
    deinit {
        println("*** deinit \(self)")
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    
    
    @IBAction func done() {
      let hudView = HudView.hudInView(navigationController!.view, animated: true)
      hudView.text = "Sweet"
        var place: Places
        if let temp = placeToEdit {
            hudView.text = "Updated"
            place = temp
            println("1")
            
        } else {
            hudView.text = "Tagged"
            place = NSEntityDescription.insertNewObjectForEntityForName("Places", inManagedObjectContext: managedObjectContext) as! Places
            place.photoID = nil
            println("1****Something went wrong")
        }
        
    //1
        
        place.locationDescription = descriptionText
        place.category = categoryName
        place.latitude = coordinate.latitude
        place.longitude = coordinate.longitude
        place.date = date
        place.placemark = placemark
        
        if let image = image {
            //1 - Get a new ID and assign it to the places photoID property, but only if adding a photo to a location that didn't already have one.  If one existed, simply keep same ID and overwrite existing JPEG.
            if !place.hasPhoto {
                place.photoID = Places.nextPhotoID()
            }
            
            //2 Convert image into JPEG and returns an NSData object.
            let data = UIImageJPEGRepresentation(image, 0.5)
            //3 Save the NSData object to the path given by the photoPath property.
            var error: NSError?
            if !data.writeToFile(place.photoPath, options: .DataWritingAtomic, error: &error){
                println("Error writing file: \(error)")
                
            }
        }
        var error: NSError?
        if !managedObjectContext.save(&error) {
            fatalCoreDataError(error)
            return
        }
        afterDelay(0.6) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancel() {
    dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let place = placeToEdit {
            title = "Edit Places"
            
            if place.hasPhoto {
                if let image = place.photoImage{
                    showImage(image)
                }
            }
            
        }
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = formatDate(date)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        listenForBackgroundNotification()
        
    }
    func listenForBackgroundNotification() {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] notification in
        
            if let strongSelf = self {
            if strongSelf.presentedViewController != nil {
                strongSelf.dismissViewControllerAnimated(false, completion: nil)
            }
        strongSelf.descriptionTextView.resignFirstResponder()
        }
    }
}
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        return
            "\(placemark.subThoroughfare) \(placemark.thoroughfare), " + "\(placemark.locality)," + "\(placemark.administrativeArea) \(placemark.postalCode)," + "\(placemark.country)"
    }
    
    func formatDate(date: NSDate) ->String {
        return dateFormatter.stringFromDate(date)
    }
    func showImage(image: UIImage) {
        imageView.image = image
        imageView.hidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.hidden = true
        
    }
    
    //MARK: -UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        
        // corresponds to section 0, row 0.
        case (0, 0):
            return 88
        // corresponds to section 1, any row.
        case (1, _):
        // remember that ? is a ternary operator.  Works like an if - else compressed in a single line.  If the thing before the ? is true, it returns the 1st value, 2nd if not.
            
            return imageView.hidden ? 44 : 280
        // coresponds to section 2, row 2
        case (2, 2):
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 1000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
            
        default:
            return 44
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            pickPhoto()
        }
    }
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0{
                return
            println("Something is wrong here")
            
        }
        descriptionTextView.resignFirstResponder()
    }
    
}

extension LocationDetailsViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        descriptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        return true
    }
    func textViewDidEndEditing(textView: UITextView) {
    descriptionText = textView.text
    }
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if let image = image {
            showImage(image)
        }
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)

    }
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
        
    }
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: { _ in self.takePhotoWithCamera() })
        alertController.addAction(takePhotoAction)
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: { _ in self.choosePhotoFromLibrary() })
        alertController.addAction(chooseFromLibraryAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }

}


