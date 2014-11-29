//
//  ViewController.swift
//  Compass
//
//  Created by mario on 14/11/29.
//
//

import UIKit
import CoreLocation

let arrowAnimationKey: String = "arrowRotationAnimation"

func degressToRadians(angle: Double) -> Double {
    return angle * M_PI / 180.0
}

class ViewController: UIViewController {

    @IBOutlet weak var arrowView: UIView!
    
    private var locationManager: CLLocationManager!
    private var animation: CABasicAnimation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.animation == nil {
            self.animation = CABasicAnimation(keyPath: "transform.rotation")
            self.animation.duration = 1
            self.animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.animation.fromValue = degressToRadians(0.0)
            self.animation.toValue = degressToRadians(360.0)
            self.arrowView.layer.addAnimation(self.animation, forKey: arrowAnimationKey)
            self.arrowView.layer.speed = 0
        }
        
        self.locationManager.startUpdatingHeading()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        var timeOffset = degressToRadians(360 - newHeading.trueHeading) / degressToRadians(360)
        self.arrowView.layer.timeOffset = timeOffset
    }
}