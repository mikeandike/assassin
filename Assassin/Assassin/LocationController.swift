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
            
            guard let location = currentLocation else { print("something went horribly wrong"); return }
            FirebaseNetworkController.sharedInstance.currentPerson!.lastLocation = location
            FirebaseNetworkController.sharedInstance.currentPerson!.timeAtLastLocation = location.timestamp
            
            let person = FirebaseNetworkController.sharedInstance.currentPerson!
            let geoFire = FirebaseNetworkController.sharedInstance.geoFire()
            
            geoFire.setLocation(currentLocation, forKey: person.uid)
            let locationDict = FirebaseNetworkController.sharedInstance.saveLocationIntoDictionary(location)
            FirebaseNetworkController.sharedInstance.getUsersRef().childByAppendingPath(person.uid).childByAppendingPath("lastLocation").setValue(locationDict)
            
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
            NSNotificationCenter.defaultCenter().postNotificationName("locationUnavailable", object: "Your device's location services are not turned on,\ror are otherwise unavailable.")
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
        
        NSNotificationCenter.defaultCenter().postNotificationName("locationUnavailable", object: "unable to get location error: \(error.localizedDescription)")
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
            
            // *** here is where we filter for time??? ***
            
            FirebaseNetworkController.sharedInstance.addPersonWithUIDAndLocationToPeopleNearby(key, location: location, locationOfCurrentUser: currentLocation)
        })
        
        circleQuery.observeEventType(GFEventTypeKeyExited, withBlock: { (key: String!, location: CLLocation!) in
            
            FirebaseNetworkController.sharedInstance.removePersonWithUIDFromPeopleNearby(key)
            
            // next three lines, gets user's location again if they've moved out of the area
            if let currentPerson = FirebaseNetworkController.sharedInstance.currentPerson {

                if key == currentPerson.uid {
                    FirebaseNetworkController.sharedInstance.peopleNearby = []
                    self.getLocation()
                }
            }
        })
    }
    
}

