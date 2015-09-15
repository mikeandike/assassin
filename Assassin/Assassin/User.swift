//
//  User.swift
//  Assassin
//
//  Created by Michael Sacks on 9/15/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit
import CoreLocation

class User: NSObject {
    
    var lastLocation : CLLocation?
    var timeOfLastLocationUpdate: NSDate?
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var phoneNumber: String?
    
    var password: String?
    
    var jobTitle: String?
    var company: String?
    
    var image: UIImage?
    
    var starredUsers: [User]?
   
}

