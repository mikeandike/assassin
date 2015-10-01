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
    
    static let sharedInstance = LocationController()

    var currentLocation: CLLocation?
    
    var locationManager:CLLocationManager!
    
    var hasPerson : Bool
    
    var hasLocation : Bool
    
//    var currentlyRefreshing : Bool = false
    
    override init () {
        
        hasPerson = false
        hasLocation = false
        super.init()
        registerForNotifications()
        
    }
    
    func sendLocationToFirebase() {
        
        if hasPerson == true && hasLocation == true {
            
        FirebaseNetworkController.sharedInstance.currentPerson!.lastLocation = currentLocation
        FirebaseNetworkController.sharedInstance.currentPerson!.timeAtLastLocation = currentLocation!.timestamp
            
        let person = FirebaseNetworkController.sharedInstance.currentPerson!
            
        let geoFireRef = Firebase(url: FirebaseNetworkController.sharedInstance.getBaseUrl())
        let geoFire = GeoFire(firebaseRef: geoFireRef)
            
            geoFire.setLocation(currentLocation, forKey: person.uid)
            
            print("person has been sent to firebase: person: \(person)")
            
            hasLocation = false
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "personArrived", name: "userExistsNotification", object: nil)
        
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
        
//        currentlyRefreshing = true
        
        let geoFireRef = Firebase(url: FirebaseNetworkController.sharedInstance.getBaseUrl())
        let geoFire = GeoFire(firebaseRef: geoFireRef)
        
        let center = currentLocation;
        let circleQuery = geoFire.queryAtLocation(center, withRadius: 0.6)
        let currentUserQuery = geoFire.queryAtLocation(center, withRadius: 500000)
        
        circleQuery.observeReadyWithBlock { () -> Void in
            
            //Notification fires when main batch of users nearby comes back from query
            NSNotificationCenter.defaultCenter().postNotificationName("usersNearbyQueryFinishedNotification", object: nil)
            
        }
        
        circleQuery.observeEventType(GFEventTypeKeyEntered, withBlock: { (key: String!, location: CLLocation!) in
            
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            
            
            FirebaseNetworkController.sharedInstance.addPersonWithUIDAndLocationToPeopleNearby(key, location: location, locationOfCurrentUser: currentLocation)
            
           
        })
        
        circleQuery.observeEventType(GFEventTypeKeyExited, withBlock: { (key: String!, location: CLLocation!) in
            
            FirebaseNetworkController.sharedInstance.removePersonWithUIDFromPeopleNearby(key)
            
        })
        
        
        if let currentPerson = FirebaseNetworkController.sharedInstance.currentPerson {
            
            currentUserQuery.observeEventType(GFEventTypeKeyMoved, withBlock: { (key: String!, location:CLLocation!) in
                
                if key == currentPerson.uid {
                    
                    if let lastLocation = currentPerson.lastLocation {
                        
                        if location.distanceFromLocation(lastLocation) > 400 {
                            
                            self.getLocation()
                            
                        }
                        
                    }
                }
                
            })
            
        }
        
        //make sure that both are happening and not overriding each other
        
       
        
    }
    
    
}
