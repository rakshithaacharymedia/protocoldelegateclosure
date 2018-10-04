//
//  ArViewController.swift
//  DemoApp
//
//  Created by rakshitha on 03/10/18.
//  Copyright © 2018 rakshitha. All rights reserved.
//

import UIKit
import ARKit
import CoreLocation

class ArViewController: UIViewController{
    @IBOutlet weak var sceneView: ARSCNView!
    var source: CLLocation?
    var destination: CLLocation?
    var sourceNode = SCNNode()
    var destinationNode = SCNNode()
    var angle: Double = 0.0
    var distance: Double = 0.0
    var sourcePosition  = SCNVector3()
    var destinationPosition = SCNVector3()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration)
        addbox()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let source = source ,let destination = destination {
            angle =   getBearingBetweenTwoPoints1(source: source, destination: destination)
            print(angle)
            distance = (source.distance(from: destination) as? Double)!
            print(distance)
            placeDestination(distance: distance,angle: angle)
      }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func addbox() {
    let sourceBox = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
    sourceNode.geometry = sourceBox
    sourceNode.position = SCNVector3(0,0,0)
    //sourcePosition = (0,0,0)
    sceneView.scene.rootNode.addChildNode(sourceNode)
    }
    func placeDestination(distance: Double,angle: Double) {
        let destinationBox = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
        destinationNode.geometry = destinationBox
        destinationNode.position = SCNVector3(0,0,-distance)
        let translationMatrix = translate(distance: distance)
        let rotationMatrix = rotateAroundY(angle: Float(angle))
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        //destinationNode.transform = (transformMatrix)
        sceneView.scene.rootNode.addChildNode(sourceNode)
        
    }
    func translate(distance: Double) -> matrix_float4x4 {
           var matrix = matrix_float4x4()
        matrix.columns.3.z = Float(-distance)
           return matrix
    }
    func rotateAroundY(angle: Float) -> matrix_float4x4 {
        var matrix = matrix_float4x4()
        
        matrix.columns.0.x = cos(angle)
        matrix.columns.0.z = -sin(angle)
        matrix.columns.1.y = 1
        matrix.columns.3.w = 1
        matrix.columns.2.x = sin(angle)
        matrix.columns.2.z = cos(angle)
        return matrix.inverse
    }
    func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    func radiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
    func getBearingBetweenTwoPoints1(source : CLLocation, destination : CLLocation) -> Double {
        let lat1 = degreesToRadians(degrees: source.coordinate.latitude)
        let lon1 = degreesToRadians(degrees: source.coordinate.longitude)
        let lat2 = degreesToRadians(degrees: destination.coordinate.latitude)
        let lon2 = degreesToRadians(degrees: destination.coordinate.longitude)
        let dLon = lon2 - lon1
        let x = sin(dLon) * cos(lat2)
        let y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(x, y)
        return  radiansToDegrees(radians: radiansBearing)
    }
}
extension ArViewController: ARSCNViewDelegate {
    
}


