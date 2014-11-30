//
//  CLLocation+Bearing.swift
//  Compass
//
//  Created by mario on 14/11/30.
//
//

import CoreLocation

func degreesToRadians(degrees: Double) -> Double {
    return degrees * (M_PI / 180.0)
}

func radiansToDegress(radians: Double) -> Double {
    return radians * (180.0 / M_PI)
}

extension CLLocation {
    func bearingToLocation(location: CLLocation) -> Double {
        var lat1 = degreesToRadians(self.coordinate.latitude)
        var lon1 = degreesToRadians(self.coordinate.longitude)
        
        var lat2 = degreesToRadians(location.coordinate.latitude)
        var lon2 = degreesToRadians(location.coordinate.longitude)
        
        var dLon = lon2 - lon1
        
        var y = sin(dLon) * cos(lat2)
        var x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var radiansBearing = atan2(y, x)
        if radiansBearing < 0.0 {
            radiansBearing += 2 * M_PI
        }
        
        return radiansBearing
    }
}
