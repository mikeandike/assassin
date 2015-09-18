//
//  LocationController.swift
//  Assassin
//
//  Created by Rutan on 9/15/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase



class LocationController: NSObject, CLLocationManagerDelegate {
    
    var location: CLLocation?
    
    var locationManager:CLLocationManager!
    
    var hasPerson : Bool
    
    var hasLocation : Bool
    
    override init () {
        
        hasPerson = false
        hasLocation = false
        registerForNotifications()
        
        
    }
    
    func sendLocationToFirebase() {
        
        if hasPerson == true && hasLocation == true {
            
        FirebaseNetworkController.sharedInstance.currentPerson!.lastLocation = location
            
        let person = FirebaseNetworkController.sharedInstance.currentPerson!
            
        let geoFireRef = Firebase(url: FirebaseNetworkController.sharedInstance.getBaseUrl())
        let geoFire = GeoFire(fireBaseRef: geoFireRef)
            
            geoFire.setLocation(location, forKey: person.uid)
        
        }
    }
    
    func personArrived() {
       
        hasPerson = true
        
        sendLocationToFirebase()
        
    }
    
    func locationArrived() {
        
        hasLocation = true
        
        sendLocationToFirebase()
    }
    
    func registerForNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "personArrived:", name: "userExistsNotification", object: nil)
        
    }
    
    //MARK: get location method
    
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
        
        location = locations[locations.count - 1]
        
        print("locations are: \(locations)")
        
        locationArrived()
        
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        //message to user about 'unable to get location'
        print("unable to get location error: \(error)")
    }
    
    
}
