//
//  DataStore.swift
//  DemoApp
//
//  Created by rakshitha on 22/09/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataStore {
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func insert(nearbyPlaceDict: [String:Any]) {
        if let entity = NSEntityDescription.insertNewObject(forEntityName: "Place", into: context!) as? Place {
        if let result = nearbyPlaceDict["results"] as? [[String: Any]] {
            for obj in result.enumerated() {
                if let dict = obj.element as? [String: Any] {
                    if let geometry = dict["geometry"] as? [String: Any] {
                        if let location = geometry["location"] as? [String: Any] {
                            if let latitude = location["lat"] as? Double {
                                entity.latitude = latitude
                                
                            }
                            if let longitude = location["lng"] as? Double {
                                entity.longitude = longitude
                        }
                    }
                    if let type = dict["types"] as? [String] {
                      entity.typeofPlace  = type[0]
                    }
                    if let name = dict["name"] as? String {
                         entity.name  = name
                    }
                    if let icon = dict["icon"]  as? String {
                        entity.icon = icon
                    }
                    if let vicinity = dict["vicinity"]  as? String {
                        entity.vicinity = vicinity
                    }
               do {
                  try context?.save()
                  } catch {
                    print("error")
                 }
               }
            }
         }
       }
    }
 }
    func fetch() -> [Place] {
        let request = NSFetchRequest<Place>(entityName: "Place")
        var nearbyPlace = [Place]()
        do {
            if let result = try context?.fetch(request) {
                nearbyPlace = result
            }
          } catch {
            print("error")
        }
        return nearbyPlace
    }
}

