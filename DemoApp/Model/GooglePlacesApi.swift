//
//  GooglePlacesApi.swift
//  DemoApp
//
//  Created by rakshitha on 22/09/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//
import Foundation
import GoogleMaps
import GooglePlaces
import CoreLocation
class GooglePlacesApi {

    func getNearbyplace(latitude: Double, longitude: Double, handler: @escaping ([String:Any]) -> Void) {
        let urlForNearbySearch = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=1&key=\(key)"
        let dataSession = URLSession(configuration: .default)
        let task: URLSessionDataTask?
        guard let url = URL(string: urlForNearbySearch) else { return }
        task = dataSession.dataTask(with: url) { data, _, error in
            if error == nil {
                do {
                    if let data = data {
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
                        print(json)
                        DispatchQueue.main.async {
                            handler(json)
                        }
                    }
                } catch {
                    print("error")
                    return
                }
            }
        }
        task?.resume()
    }

    //get image for marker from web
    func getImageFromWeb(url: String, closure: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: url) else {
            return closure(nil)
        }
        let task = URLSession(configuration: .default).dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("error: \(String(describing: error))")
                return closure(nil)
            }
            guard response != nil else {
                print("no response")
                return closure(nil)
            }
            guard let data = data else { return }
            DispatchQueue.main.async {
                closure(UIImage(data: data))
            }
        }
        task.resume()
    }
    //get address from given latitude and longitude
    func getAddress(latitudes: Double, longitudes: Double, handler: @escaping ([String: Any]) -> Void) {
        var address = [String: Any]()
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitudes, longitude: longitudes)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error -> Void in
            if (error) == nil {
                if let place = placemarks?[0] {
                    if let locality = place.locality {
                        address["locality"] = locality
                    }
                    if let sublocality = place.subLocality {
                        address["sublocality"] = sublocality
                    }
                    if let country = place.country {
                        address["country"] = country
                    }
                    if let postalcode = place.postalCode {
                        address["postalcode"] = postalcode
                    }
                    if let formattedaddress = place.description as? String
                    {
                        address["formattedaddress"] = formattedaddress
                    }
                    if let name = place.name {
                        address["name"] = name
                    }
                }
                handler(address)
            }
        })
    }
    func getplaceCordinate(placeId: String, handler: @escaping (CLLocationCoordinate2D) -> Void) {
        var placeCordinate = CLLocationCoordinate2D()
        let urlforPlaceDetail = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&fields=geometry&key=\(key)"
        let dataSession = URLSession(configuration: .default)
        let task: URLSessionDataTask?
        guard  let url = URL(string: urlforPlaceDetail) else { return }
        task = dataSession.dataTask(with: url) { data, _, error in
           if error != nil {
                    print("error")
                }
                do {
                if let data = data {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(json)
                    if let result = json["result"] as? [String: Any] {
                        if let geometry = result["geometry"] as? [String: Any] {
                            if let location = geometry["location"] as? [String: Any] {
                                guard  let latitude = location["lat"] as? Double else { return }
                                guard  let longitude = location["lng"] as? Double else { return }
                                placeCordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            }
                         }
                        }
                       }
                    }
                    DispatchQueue.main.async {
                        handler(placeCordinate)
                    }
                } catch {
                print("error")
            }
          }
        task?.resume()
    }
    func getRoute(srcLat: Double, srcLng: Double, desLat: Double, desLng: Double, handler: @escaping(String) -> Void) {
        var routePoints: String = " "
        let dataSession = URLSession(configuration: .default)
        let task: URLSessionDataTask?
         let urlforRoute = "https://maps.googleapis.com/maps/api/directions/json?origin=\(srcLat),\(srcLng)&destination=\(desLat),\(desLng)&mode=\(mode)&key=\(key)"
        guard let url = URL(string: urlforRoute) else { return }
        task = dataSession.dataTask(with: url) { data, _, error in
            if  error != nil {
                print("error")
            }
            do {
            if let data = data {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                      print(json)
                    if let routes = json["routes"] as? NSArray {
                        if let routeDict = routes.firstObject as? [String:Any] {
                            if let overview_polyline = routeDict["overview_polyline"] as? [String: Any] {
                               if let points = overview_polyline["points"] as? String {
                                  routePoints = points
                            }
                        }
                  }
             }
        }
   }
                DispatchQueue.main.async {
                    handler(routePoints)
                }
            } catch {
                print("error")
            }
        }
    task?.resume()
  }
}
