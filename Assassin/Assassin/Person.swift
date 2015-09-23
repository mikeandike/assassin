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
    
    var uid: String
    var password: String
    
    var phoneNumber: String?
    
    //should set this so that time at last location is set with lastLocation.timestamp when last location is assigned to user
    var lastLocation : CLLocation?
    var timeAtLastLocation: NSDate?
    
    var jobTitle: String?
    var company: String?
    var bio: String?
    var purpose: String?
    
    //still have to figure out how to transfer images through firebase
    var image: UIImage?
    
    var starredUsers: [Person]?
    
    init(firstName: String, lastName: String, email: String, password: String, uid: String) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.uid = uid
        
    }
    
    init(dictionary: [String:AnyObject]) {
        
        self.firstName = dictionary["firstName"] as! String
        
        self.lastName = dictionary["lastName"] as! String
        
        self.email = dictionary["email"] as! String
        
        self.password = dictionary["password"] as! String
        
        self.uid = dictionary["uid"] as! String
        
        if let phoneNumber = dictionary["phoneNumber"] {
            
            self.phoneNumber = phoneNumber as? String
            
        }
        
        if let jobTitle = dictionary["jobTitle"] {
            
            self.jobTitle = jobTitle as? String
            
        }
        
        if let company = dictionary["company"] {
            
            self.company = company as? String
            
        }
        
        if let bio = dictionary["bio"] {
            
            self.bio = bio as? String
        }
        
        if let purpose = dictionary["purpose"] {
            
            self.purpose = purpose as? String
        }
        
        if let starredUsers = dictionary["starredUsers"] {
            
            self.starredUsers = starredUsers as? [Person]
            
        }
        
        
        super.init()
        
        
        if let locationDictionary = dictionary["lastLocation"] {
            
            self.getCLLocationFromDictionary(locationDictionary as! [String : AnyObject])
            
        }
        
        
        if let imageString = dictionary["imageString"] {
            
            self.convertStringToImage(imageString as! String)
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
        
        if let secondsSince1970 = locationDictionary["timestamp"] as? NSTimeInterval {
            
            let timestamp = NSDate.init(timeIntervalSince1970: secondsSince1970)
            
            self.timeAtLastLocation = timestamp
            
        }
        
        
        self.lastLocation = location
        
        }
    
    
    func convertStringToImage(imageString: String) {
  
        let imageData = NSData(base64EncodedString: imageString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        if let imageData = imageData {
            
            image = UIImage(data: imageData)

       }
        
        
    }
    
    

    
    
   
}



