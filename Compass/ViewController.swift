//
//  ViewController.swift
//  Compass
//
//  Created by mario on 14/11/29.
//
//

import UIKit
import CoreLocation
import CoreMotion

let kaabaLocation: CLLocation = CLLocation(latitude: 21.422460825623126, longitude: 39.82620057548526)

class ViewController: UIViewController {

    @IBOutlet weak var arrowView: UIView!
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.headingAvailable() == false {
            println("Heading service is not available.")
            return
        }
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 20
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingHeading()
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.headingAvailable() == false {
            var alert: UIAlertController = UIAlertController(
                title: "提示",
                message: "设备不支持指向功能",
                preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Default,
                handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        var transform = CATransform3DIdentity
        if self.currentLocation != nil {
            var radians = self.currentLocation.bearingToLocation(kaabaLocation)
            transform = CATransform3DMakeRotation(CGFloat(degreesToRadians(-newHeading.trueHeading) + radians), 0, 0, 1)
        }
        self.arrowView.layer.transform = transform
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var count = locations.count
        if count <= 0 {
            return
        }
        
        if self.currentLocation != nil {
            return
        }
        
        self.currentLocation = locations.first as CLLocation
        self.locationManager.stopUpdatingLocation()
        println("currentLocation \(currentLocation)")
    }
}
