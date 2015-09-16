//
//  User.swift
//  Assassin
//
//  Created by Michael Sacks on 9/15/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit
import CoreLocation

class Person: NSObject {
    
    var firstName: String
    var lastName: String
    var email: String
    
    var password: String
    
    var phoneNumber: String?
    
    var lastLocation : CLLocation?
    
    var jobTitle: String?
    var company: String?
    
    //still have to figure out how to transfer images through firebase
    var image: UIImage?
    
    var starredUsers: [Person]?
    
    init(firstName: String, lastName: String, email: String, password: String) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        
    }
    
    init(dictionary: [String:AnyObject]) {
        
        self.firstName = dictionary["firstName"] as! String
        
        self.lastName = dictionary["lastName"] as! String
        
        self.email = dictionary["email"] as! String
        
        self.password = dictionary["password"] as! String
        
        if let phoneNumber = dictionary["phoneNumber"] {
            
            self.phoneNumber = phoneNumber as? String
            
        }
        
        if let jobTitle = dictionary["jobTitle"] {
            
            self.jobTitle = jobTitle as? String
            
        }
        
        if let company = dictionary["company"] {
            
            self.company = company as? String
            
        }
        
        if let starredUsers = dictionary["starredUsers"] {
            
            self.starredUsers = starredUsers as? [Person]
            
        }
        
        
        super.init()
        
        
        if let locationDictionary = dictionary["lastLocation"] {
            
            self.getCLLocationFromDictionary(locationDictionary as! [String : AnyObject])
            
        }
     
        
    }
    
    
    func getCLLocationFromDictionary(locationDictionary : [String : AnyObject]) {
        
        var location = CLLocation()
        
        var latitude = Double()
        var longitude = Double()
        
            
            if let latitudeString = locationDictionary["latitude"] as? String {
                
                latitude = (latitudeString as NSString).doubleValue
                
            }
            
        if let longitudeString = locationDictionary["longitude"] as? String {
                
                longitude = (longitudeString as NSString).doubleValue
            }
            
            location = CLLocation.init(latitude: latitude, longitude: longitude)
        
    
       //we need to get timestap back onto last location
        
        self.lastLocation = location
        
        }
    
    

    
    
   
}



