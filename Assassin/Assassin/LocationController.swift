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
    
    var currentLocation: CLLocation?
    
    var locationManager:CLLocationManager!
    
    var hasPerson : Bool
    
    var hasLocation : Bool
    
    override init () {
        
        hasPerson = false
        hasLocation = false
        super.init()
        registerForNotifications()
        
    }
    
    func sendLocationToFirebase() {
        
        if hasPerson == true && hasLocation == true {
            
        FirebaseNetworkController.sharedInstance.currentPerson!.lastLocation = currentLocation
            
        let person = FirebaseNetworkController.sharedInstance.currentPerson!
            
        let geoFireRef = Firebase(url: FirebaseNetworkController.sharedInstance.getBaseUrl())
        let geoFire = GeoFire(firebaseRef: geoFireRef)
            
            geoFire.setLocation(currentLocation, forKey: person.uid)
        
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
    
//MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[locations.count - 1]
        
        print("locations are: \(locations)")
        
        locationArrived()
        
        if let currentUserLocation = currentLocation {
        
        getUIDsOfUsersAtNearbyLocation(currentUserLocation)
            
        }
        
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        //message to user about 'unable to get location'
        print("unable to get location error: \(error.localizedDescription)")
    }
    
    
//MARK: - query locations of Nearby Users
    
    func getUIDsOfUsersAtNearbyLocation(currentLocation : CLLocation) {
        
        let geoFireRef = Firebase(url: FirebaseNetworkController.sharedInstance.getBaseUrl())
        let geoFire = GeoFire(firebaseRef: geoFireRef)
        
        let center = currentLocation;
        let circleQuery = geoFire.queryAtLocation(center, withRadius: 0.6)
        
        circleQuery.observeEventType(GFEventTypeKeyEntered, withBlock: { (key: String!, location: CLLocation!) in
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            
            FirebaseNetworkController.sharedInstance.addPersonWithUIDAndLocationToPeopleNearby(key, location: location)
            
        })
        
        //make sure that both are happening and not overriding each other
        
        circleQuery.observeEventType(GFEventTypeKeyExited) { (key: String!, location: CLLocation!) in
            
            
            
        }
        
    }
    
    
}
