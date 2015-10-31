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
    var locationManager: CLLocationManager!
    var hasPerson : Bool = false
    var hasLocation : Bool = false
    
    override init () {
        super.init()
        
        registerForNotifications()
    }
    
    func sendLocationToFirebase() {
        
        if hasPerson == true && hasLocation == true {
            
            FirebaseNetworkController.sharedInstance.currentPerson!.lastLocation = currentLocation
            FirebaseNetworkController.sharedInstance.currentPerson!.timeAtLastLocation = currentLocation!.timestamp
            
            let person = FirebaseNetworkController.sharedInstance.currentPerson!
            
            //maybe would be nice to put an extension path here for geofire locations
            let geoFireRef = Firebase(url: FirebaseNetworkController.sharedInstance.getBaseUrl())
            let geoFire = GeoFire(firebaseRef: geoFireRef)
            
            geoFire.setLocation(currentLocation, forKey: person.uid)
            
            // maybe we should save the user's own location to firebase in this method, otherwise it's only saving/updating when they save their profile
            
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
            //present alert explaining why we need location
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.delegate = self
            locationManager.requestLocation()
            
        } else {
            //alert or something that 'location services are unavailable' or whatever we want to say/do
            print("location services are unavailable")
        }
    }
    
    //MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[locations.count - 1]
        
        if let currentUserLocation = currentLocation {
            
            getUIDsOfUsersAtNearbyLocation(currentUserLocation)
        }
        locationArrived()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        //message to user about 'unable to get location'
        print("unable to get location error: \(error.localizedDescription)")
    }
    
    //MARK: - query locations of Nearby Users
    
    func getUIDsOfUsersAtNearbyLocation(currentLocation : CLLocation) {
        
        let fireRef = Firebase(url: FirebaseNetworkController.sharedInstance.getBaseUrl())
        let geoFireRef = GeoFire(firebaseRef: fireRef)
        
        let circleQuery = geoFireRef.queryAtLocation(currentLocation, withRadius: 0.05)
        
        circleQuery.observeReadyWithBlock { () -> Void in
            
            //Notification fires when main batch of users nearby comes back from query
            NSNotificationCenter.defaultCenter().postNotificationName("usersNearbyQueryFinishedNotification", object: nil)
        }
        
        circleQuery.observeEventType(GFEventTypeKeyEntered, withBlock: { (key: String!, location: CLLocation!) in
            
            FirebaseNetworkController.sharedInstance.addPersonWithUIDAndLocationToPeopleNearby(key, location: location, locationOfCurrentUser: currentLocation)
        })
        
        circleQuery.observeEventType(GFEventTypeKeyExited, withBlock: { (key: String!, location: CLLocation!) in
            
            FirebaseNetworkController.sharedInstance.removePersonWithUIDFromPeopleNearby(key)
            
            // should this be in its own method?
            // next three lines, gets user's location again if they've moved out of the area
            if let currentPerson = FirebaseNetworkController.sharedInstance.currentPerson {

                if key == currentPerson.uid {
                    self.getLocation()
                }
            }
        })
    }
    
}

