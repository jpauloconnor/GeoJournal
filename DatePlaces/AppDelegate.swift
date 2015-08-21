//
//  AppDelegate.swift
//  DatePlaces
//
//  Created by Paul O'Connor on 8/18/15.
//  Copyright (c) 2015 OCApps. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var managedObjectContext: NSManagedObjectContext = {
        //1 - Path to the CoreData folder.
        if let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") {
            
            //2 - Create an NSManaged object from the URL.
            if let model = NSManagedObjectModel(contentsOfURL: modelURL) {
                
                //3 - Object in charge of the SQLite database.
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                
                //4 - app's data is stored in SQLite database.  Create NSURL object that points at the DataStore.sqlite file
                let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                let documentsDirectory = urls[0] as! NSURL
                let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
                
                //5 - Add SQLite database to the store coordinator.
                var error: NSError?
                if let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) {
                    //6 - create NSManO and return it.
                    let context = NSManagedObjectContext()
                    context.persistentStoreCoordinator = coordinator
                    return context
                    //7 - Print an error message.
                } else {
                    println(
                        "Error adding persistent store at \(storeURL): \(error!)")
                }
            } else {
                println("Error initializing model from: \(modelURL)")
            }
        } else {
            println("Could not find data model in app bundle")
        }
        
        abort()
        }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //Get a ref to CLVC by finding UITabC and then check it's array.
        let tabBarController = window!.rootViewController as! UITabBarController
        
        if let tabBarViewControllers = tabBarController.viewControllers {
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            currentLocationViewController.managedObjectContext = managedObjectContext
        }
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

