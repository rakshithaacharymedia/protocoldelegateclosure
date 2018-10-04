//
//  ViewController.swift
//  DemoApp
//
//  Created by rakshitha on 19/09/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation
import GooglePlacePicker
import CoreData

var mode: String = "walking"

class ViewController: UIViewController {
    @IBOutlet weak var arkitNavigationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewForDirection: UIView!
    @IBOutlet weak var sourceTextField: UITextField! {
        didSet {
            sourceTextField.layer.borderColor = UIColor.black.cgColor
            sourceTextField.layer.borderWidth = 2.0
        }
    }
    @IBOutlet weak var destinationTextField: UITextField! {
        didSet {
            destinationTextField.layer.borderColor = UIColor.black.cgColor
            destinationTextField.layer.borderWidth = 2.0
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var containerView: UIView!
    var selectedTextField: UITextField!
    var mapView: GMSMapView?
    var information: InformationWindow? {
        didSet {
            information?.layer.borderColor = UIColor.white.cgColor
            information?.layer.borderWidth = 2.0
        }
    }
    let googleApi = GooglePlacesApi()
    let coreDataObject = DataStore()
    let locationManager = CLLocationManager()
    var camera = GMSCameraPosition()
    var arrayAddress = [GMSAutocompletePrediction]()
    var filter: GMSAutocompleteFilter {
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        return filter
    }
    var polyline: GMSPolyline?
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var srcLat: Double = 0.0
    var srcLng: Double = 0.0
    var destLat: Double = 0.0
    var destLng: Double = 0.0
    var srcName: String = " "
    var destName: String = " "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManagerInit()
        mapInit()
        tableInit()
        searchBarInit()
    }
    override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
    }
    func locationManagerInit() {
         locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
         locationManager.requestWhenInUseAuthorization()
         locationManager.startUpdatingLocation()
    }
    func textFieldInit(srcName: String,destName: String) {
        sourceTextField.text = srcName
        destinationTextField.text = destName
        destinationTextField.delegate = self
        sourceTextField.delegate = self
    }
    func mapInit() {
        mapView = GMSMapView()
        mapView?.frame = UIScreen.main.bounds
        mapView?.delegate = self
        if let mapView = mapView {
        containerView.addSubview(mapView)
        }
    }
    func tableInit() {
        tableView.isHidden = true
    }
    func viewForDirectionInit(viewForDirection: UIView,containerView: UIView) {
        viewForDirection.isHidden = true
        containerView.addSubview(viewForDirection)
    }
    
    func searchBarInit() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        resultsViewController?.tintColor = UIColor.white
        resultsViewController?.primaryTextHighlightColor = UIColor.blue
        resultsViewController?.primaryTextColor = UIColor.darkText
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.placeholder = "Enter Location"
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.barTintColor = UIColor.red
        searchController?.searchBar.backgroundImage = UIImage()
        searchController?.searchBar.delegate = self
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    @IBAction func backButton(_ sender: Any) {
        self.viewForDirection.isHidden = true
        navigationController?.isNavigationBarHidden = false
        tableView.isHidden = true
        mapView?.frame = UIScreen.main.bounds
        if let polyline = polyline {
            polyline.map = nil
        }
    }
    @IBAction func travelModeSelected(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        switch button.tag {
            case 1:
                 mode = "driving"
            case 3:
                  mode = "bicycling"
             default:
                    mode = "walking"
              }
       googleApi.getRoute(srcLat: srcLat, srcLng: srcLng, desLat: destLat, desLng: destLng) { points in
            self.displayPath(points: points)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVc = segue.destination as! ArViewController
        destinationVc.source = CLLocation(latitude: srcLat, longitude: srcLng)
        destinationVc.destination = CLLocation(latitude: destLat, longitude: destLng)
    }
    func getCurrentLocation() {
        guard let lat = locationManager.location?.coordinate.latitude else { return }
        guard let lng = locationManager.location?.coordinate.longitude else { return }
        srcLat = lat
        srcLng = lng
        camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 15)
        mapView?.camera = camera
        mapView?.settings.myLocationButton = true
        mapView?.isMyLocationEnabled = true
        googleApi.getAddress(latitudes: lat, longitudes: lng) { address in
            guard let name = address["locality"] as? String else { return }
            guard let address = address["sublocality"] as? String else { return }
            self.setMarker(lat: self.srcLat, long: self.srcLng, name: name, address: address, returnMarker: false,mapView: self.mapView!)
            self.srcName = name
         }
     }
    func setMarker(lat: Double,long: Double,name: String,address: String,returnMarker: Bool,mapView: GMSMapView) -> GMSMarker? {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = name
        marker.snippet = address
        if returnMarker {
            return marker
        } else {
            marker.map = mapView
            return nil
        }
    }
    func tableRowSelected (arrayDetails: GMSAutocompletePrediction,selectedTextField: UITextField)
    {
        selectedTextField.text =  arrayDetails.attributedPrimaryText.string
        googleApi.getplaceCordinate(placeId: arrayDetails.placeID!) { placeCordinate in
            self.setMarker(lat: placeCordinate.latitude, long: placeCordinate.longitude, name: arrayDetails.attributedPrimaryText.string, address: arrayDetails.attributedFullText.string,returnMarker: false, mapView: self.mapView!)
            if self.selectedTextField == self.sourceTextField {
                self.srcLat = placeCordinate.latitude
                self.srcLng = placeCordinate.longitude
            } else {
               self.destLat = placeCordinate.latitude
                self.destLng = placeCordinate.longitude
            }
            self.activityIndicator.isHidden = false
            self.googleApi.getRoute(srcLat: self.srcLat, srcLng: self.srcLng, desLat: placeCordinate.latitude, desLng: placeCordinate.longitude) { points in
                self.displayPath(points: points)
            }
        }
    }
    func displayInformation(name: String, address: String, lat: Double, lng: Double) {
      // self.information?.removeFromSuperview()
        if let information = information {
            self.information = information
            self.information?.isHidden = false
        } else {
        self.information = InformationWindow()
        self.information?.frame = CGRect(x: 0, y: self.containerView.bounds.size.height + 200, width: self.containerView.bounds.width , height: 221)
        UIView.animate(withDuration: 0.5) {
            self.information?.transform = CGAffineTransform(translationX: 0, y: -421)
            }
        }
        self.information?.nameLabel.text = name
        self.information?.placeLabel.text = address
        self.information?.directionButton.addTarget(self, action: #selector(ViewController.directionButtonClicked), for: .touchUpInside)
        destLat = lat
        destLng = lng
        destName = name
        searchController?.searchBar.text = name
        if let custview = self.information {
            self.containerView?.addSubview(custview)
        }
    }
    @objc func directionButtonClicked(sender: UIButton) {
        self.viewForDirection.isHidden = false
        self.mapView?.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        self.viewForDirection.frame = CGRect(x: 0, y: 0, width: self.viewForDirection.bounds.width, height: self.viewForDirection.bounds.height)
        information?.isHidden = true
        textFieldInit(srcName: srcName,destName: destName)
        navigationController?.isNavigationBarHidden = true
          if mapView?.frame.origin.y == UIScreen.main.bounds.origin.y {
            mapView?.frame = CGRect(x: 0, y: viewForDirection.bounds.height, width: (mapView?.bounds.width)!, height: (mapView?.frame.height)! - viewForDirection.bounds.height)
        }
       googleApi.getRoute(srcLat: srcLat, srcLng: srcLng, desLat: destLat, desLng: destLng) { points in
            self.displayPath(points: points)
        }
    }
    func displayPath(points: String) {
        let source = CLLocationCoordinate2D(latitude: srcLat, longitude: srcLng)
        let destination = CLLocationCoordinate2D(latitude: destLat, longitude: destLng)
        if points == " " {
           displayAlert(myTitle: "Failed", myMessage: "No Path Found")
        }
        if let polyline = polyline {
            polyline.map = nil
        }
        let path = GMSPath(fromEncodedPath: points)
        polyline = GMSPolyline(path: path)
        polyline?.strokeWidth = 3.0
        polyline?.strokeColor = UIColor.red
        polyline?.map = mapView
        activityIndicator.isHidden = true
        let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
        let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(100, 100, 120, 100))
        self.mapView!.moveCamera(update)
        self.mapView?.addSubview(self.arkitNavigationButton)
    }
    func toDisplay(visibleTable:Bool,VisibleMap:Bool) {
        tableView.isHidden = visibleTable
        mapView?.isHidden = VisibleMap
    }
    func displayAlert(myTitle:String,myMessage:String)
    {
        let alert = UIAlertController(title:myTitle, message: myMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func setUpSearchBar(place: GMSPlace)
    {
        searchController?.isActive = false
        camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15)
        mapView?.camera = camera
        guard let address = place.formattedAddress else { return }
        setMarker(lat: place.coordinate.latitude, long: place.coordinate.longitude, name: place.name, address: address,returnMarker: false,mapView: mapView!)
        displayInformation(name: place.name, address: address, lat: place.coordinate.latitude, lng: place.coordinate.longitude)
    }
}
extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
       googleApi.getAddress(latitudes: coordinate.latitude, longitudes: coordinate.longitude) { address in
            guard let description = address["sublocality"] as? String else { return }
            guard let name = address["name"] as? String else { return }
            self.displayInformation(name: name, address: description, lat: coordinate.latitude, lng: coordinate.longitude)
        }
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let title = marker.title else { return false }
        guard let address = marker.snippet else { return false }
        displayInformation(name: title, address: address, lat: marker.position.latitude, lng: marker.position.longitude)
        return true
    }
}
extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
        func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        setUpSearchBar(place: place)
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
      print("Error: ", error.localizedDescription)
    }
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
extension UIImage {
    func resized(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return newImage
    }
}
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        getCurrentLocation()
        locationManager.stopUpdatingLocation()
      googleApi.getNearbyplace(latitude: srcLat, longitude: srcLng) { placeDict in
        self.coreDataObject.insert(nearbyPlaceDict: placeDict )
        }
       let placeDetailArray = coreDataObject.fetch()
        for placeObj in placeDetailArray {
            guard let marker = setMarker(lat: placeObj.latitude, long: placeObj.longitude, name: placeObj.name!, address: placeObj.vicinity!,returnMarker: true,mapView: self.mapView!) else { return }
             guard let icon = placeObj.icon else { return }
            googleApi.getImageFromWeb(url: icon) { image in
                  marker.icon = image?.resized(newSize: CGSize(width: 30, height: 30))
               }
             marker.map = self.mapView
         }
    }
}
extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1 {
            selectedTextField = sourceTextField
        } else {
            selectedTextField = destinationTextField
        }
        let nsString = textField.text as NSString?
        guard  let loc = nsString?.replacingCharacters(in: range, with: string) else { return false }
        if loc == " " {
            self.arrayAddress = [GMSAutocompletePrediction] ()
        } else {
            GMSPlacesClient.shared().autocompleteQuery(loc, bounds: nil, filter: nil, callback: { result, error in
                if error == nil, let result = result {
                    self.arrayAddress = result
                    self.toDisplay(visibleTable: false, VisibleMap: true)
                    self.tableView.reloadData()
                }
            })
        }
        return true
    }
}
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayAddress.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell {
             cell.result = arrayAddress[indexPath.row]
              return cell
        }
        return UITableViewCell()
     }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.endEditing(true)
        tableView.resignFirstResponder()
        tableRowSelected(arrayDetails: arrayAddress[indexPath.row],selectedTextField: selectedTextField)
        toDisplay(visibleTable: true, VisibleMap: false)
     }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
extension ViewController: UISearchBarDelegate {
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            information?.removeFromSuperview()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text ==  " " {
            searchController?.searchBar.isUserInteractionEnabled = false
        }
    }
}





