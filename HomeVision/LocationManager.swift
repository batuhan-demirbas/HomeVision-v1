//
//  LocationManager.swift
//  HomeVision
//
//  Created by Batuhan on 29.03.2023.
//

import CoreLocation
import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    let manager = CLLocationManager()
    
    var completion: ((CLLocation) -> Void)?
    
    public func getUserLocation (completion: @escaping (CLLocation) -> Void) {
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }

    func locationManager (_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        completion?(location)
        manager.stopUpdatingLocation()
    }
    
    
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees, _ completion: @escaping (_ placemark: CLPlacemark)-> Void) {
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: latitude, longitude: longitude)
            geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Failed to retrieve address")
                    return
                }
                
                if let placemarks = placemarks, let placemark = placemarks.first {
                    completion(placemark)
                }
                else
                {
                    print("No Matching Address Found")
                }
            })
        }
}
