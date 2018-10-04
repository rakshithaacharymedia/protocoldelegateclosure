//
//  AppDelegate.swift
//  DemoApp
//
//  Created by rakshitha on 19/09/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import CoreData
let key = "AIzaSyBAaConfJ3aAo0dHsUGWr5PXh3rLAPWLLw"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   var window: UIWindow?
    
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(key)
        GMSPlacesClient.provideAPIKey(key)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
       }

    func applicationDidEnterBackground(_ application: UIApplication) {
   }

    func applicationWillEnterForeground(_ application: UIApplication) {
        }

    func applicationDidBecomeActive(_ application: UIApplication) {
      }

    func applicationWillTerminate(_ application: UIApplication) {
       }
    
     lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocationDataModel")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
              fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
             let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
