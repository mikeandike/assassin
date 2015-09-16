//
//  FirebaseNetworkController.swift
//  Assassin
//
//  Created by Michael Sacks on 9/15/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class FirebaseNetworkController: NSObject {
    
    static let sharedInstance = FirebaseNetworkController()
    
    
    func getBaseUrl() -> NSString {
        
        let baseURL = "https://assassindevmtn.firebaseio.com"
        
        return baseURL
    }
    
    
    
    func createPersonWithEmail(emailString : String, passwordString: String, firstNameString: String, lastNameString: String){
        
        let person = Person.init(firstName: firstNameString, lastName: lastNameString, email: emailString, password: passwordString)
        
        savePersonIntoDictionary(person)
        
    }
    
    
    //MARK: convert and save person into dictionary
    
    func savePersonIntoDictionary(person :Person) -> Void {
        
         let personDictionary = convertPersonIntoDictionary(person)
        
         savePersonDictionaryToFirebase(personDictionary)
        
    }
    
    //MARK: save person into dictionary
    
    func savePersonDictionaryToFirebase(dictionary : [String : AnyObject]) -> Void {
        
        let myRootRef = Firebase(url: getBaseUrl() as String)
        
        myRootRef.setValue(dictionary)
        
    }
    
   
    
    //MARK: primary method to convert person object into dictionary
    
    func convertPersonIntoDictionary(person: Person) -> [String : AnyObject] {
        
        
        var lastLocationDictionary = Dictionary<String, AnyObject>()
        
        if let lastLocation = person.lastLocation{
            
            lastLocationDictionary = saveLocationIntoDictionary(lastLocation)
            
        } else {
            
            print("person.lastLocation is null")
            
        }
        
        var imageString = "no image"
        
        if let image = person.image {
            
            imageString = convertImagetoString(image)
            
        } else {
            
            print("person.image is null")
            
        }
        
        var dictionary = Dictionary<String, AnyObject>()
        
        dictionary["firstName"] = person.firstName
        dictionary["lastName"] = person.lastName
        dictionary["email"] = person.email
        dictionary["password"] = person.password
        dictionary["phoneNumber"] = person.phoneNumber
        dictionary["jobTitle"] = person.jobTitle
        dictionary["company"] = person.company
        dictionary["starredUsers"] = person.starredUsers
        dictionary["lastLocation"] = lastLocationDictionary
        dictionary["imageString"] = imageString
    
        return dictionary
        
    }
    

    //MARK: helper methods to convert person object into dictionary
    
    func saveLocationIntoDictionary(lastLocation: CLLocation) -> [String : AnyObject] {
        
        var locationDictionary = Dictionary<String, AnyObject>()
        
        let lastLocationDate = lastLocation.timestamp
        let secondsSince1970 = lastLocationDate.timeIntervalSince1970
        
        locationDictionary["timestamp"] = secondsSince1970
        locationDictionary["longitude"] = lastLocation.coordinate.longitude
        locationDictionary["latitude"] = lastLocation.coordinate.latitude
        
        return locationDictionary
        
    }
    
    
    
    func convertImagetoString(personImage: UIImage) -> String {
        
        if let imageData = UIImageJPEGRepresentation(personImage, 0.9) {
            
            return imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            
        }
        
        return "no image"
        
    }
    
    
    

}
