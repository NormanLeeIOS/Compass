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

    @IBOutlet weak var kaabaPointerView: UIView!
    @IBOutlet weak var compassBoardView: UIImageView!
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation!
    private var isCompassBoardRotating: Bool!
    private var isUpdateEnabled: Bool!
    private var radiansToKaaba: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isCompassBoardRotating = false
        self.isUpdateEnabled = false
        
        if CLLocationManager.headingAvailable() == false {
            println("Heading service is not available.")
            return
        }
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 20
        self.locationManager.requestWhenInUseAuthorization()
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
        var headingRadians = degreesToRadians(-newHeading.trueHeading)
        if headingRadians < -M_PI {
            headingRadians += 2 * M_PI
        }
        
        if self.isUpdateEnabled == true {
            self.kaabaPointerView.layer.transform =
                CATransform3DMakeRotation(CGFloat(headingRadians + self.radiansToKaaba), 0, 0, 1)
            self.compassBoardView.layer.transform =
                CATransform3DMakeRotation(CGFloat(headingRadians), 0, 0, 1)
        } else {
            if self.isCompassBoardRotating == true {
                return
            }
            self.isCompassBoardRotating = true
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            CATransaction.setCompletionBlock({ () -> Void in
                
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                CATransaction.setCompletionBlock({ () -> Void in
                    self.isUpdateEnabled = true
                })
                
                var animation = CABasicAnimation(keyPath: "transform.rotation.z")
                animation.fromValue = 0
                animation.toValue = headingRadians + self.radiansToKaaba
                animation.duration = 1.0
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                self.kaabaPointerView.layer.addAnimation(animation, forKey: "rotationAnimation")
                
                self.kaabaPointerView.layer.transform =
                    CATransform3DMakeRotation(CGFloat(headingRadians + self.radiansToKaaba), 0, 0, 1)
                
                CATransaction.commit()
            })
            
            var animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.fromValue = 0
            animation.toValue = headingRadians
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.compassBoardView.layer.addAnimation(animation, forKey: "rotationAnimation")
            
            self.compassBoardView.layer.transform =
                CATransform3DMakeRotation(CGFloat(headingRadians), 0, 0, 1)
            
            CATransaction.commit()
        }
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
        self.radiansToKaaba = self.currentLocation.bearingToLocation(kaabaLocation)
        self.locationManager.stopUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        println("currentLocation \(currentLocation)")
    }
}
