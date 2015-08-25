//
//  LocationsViewController.swift
//  DatePlaces
//
//  Created by Paul O'Connor on 8/24/15.
//  Copyright (c) 2015 OCApps. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class PlacesViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Places", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        fetchRequest.fetchBatchSize = 20
        let fetchedResultsController = NSFetchedResultsController(
        fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "Places")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSFetchedResultsController.deleteCacheWithName("Places")
        performFetch()
        navigationItem.rightBarButtonItem = editButtonItem()
        
    }
    func performFetch() {
        var error: NSError?
        if !fetchedResultsController.performFetch(&error){
            fatalCoreDataError(error)
        }
    }
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections! [section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
        
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlacesCell") as! PlacesCell
        
        let place = fetchedResultsController.objectAtIndexPath(indexPath) as! Places
        cell.configureForLocation(place)
        
        return cell

    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let place = fetchedResultsController.objectAtIndexPath(indexPath) as! Places
            managedObjectContext.deleteObject(place)
            
            var error: NSError?
            if !managedObjectContext.save(&error) {
                fatalCoreDataError(error)
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.name
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditPlace" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
        if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
        let place = fetchedResultsController.objectAtIndexPath(indexPath) as! Places
                controller.placeToEdit = place
            }
        }

    }
    
}
extension PlacesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            println("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            println("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            println("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? PlacesCell {
                let location = controller.objectAtIndexPath(indexPath!) as! Places
                cell.configureForLocation(location)
            }
            
        case .Move:
            println("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            println("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Delete:
            println("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Update:
            println("*** NSFetchedResultsChangeUpdate (section)")
            
        case .Move:
            println("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}

