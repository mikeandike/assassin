//
//  LocationController.swift
//  Assassin
//
//  Created by Rutan on 9/15/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import Foundation
import CoreLocation

class LocationController: NSObject, CLLocationManagerDelegate {
    
    var myLocation: CLLocation?
    
    var locationManager:CLLocationManager!
    
    func getLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.delegate = self
            locationManager.requestLocation()
            
        } else {
            
            //alert or something that 'location services are unavailable' or whatever we want to say/do
            print("location services are unavailable, or whatever")
        }
    }
    
//MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        myLocation = locations[locations.count - 1]
        
        print("locations are: \(locations)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        //message to user about 'unable to get location'
        print("unable to get location error: \(error)")
    }
    
    
}
