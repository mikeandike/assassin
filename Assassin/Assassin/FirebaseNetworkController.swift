//
//  FirebaseNetworkController.swift
//  Assassin
//
//  Created by Michael Sacks on 9/15/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit

class FirebaseNetworkController: NSObject {
    
    static func getBaseUrl() -> NSString {
        
        let baseURL = "https://assassindevmtn.firebaseio.com"
        
        return baseURL
    }

}
