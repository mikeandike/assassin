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
    
    var peopleNearby : [Person]?
    var currentPerson: Person?
    var temporaryLastLocation: CLLocation?
    
    static let sharedInstance = FirebaseNetworkController()
    
    //MARK: Methods to get references to firebase server locations
    
    func getBaseUrl() -> String {
        
        let baseURL : String = "https://assassindevmtn.firebaseio.com"
        
        return baseURL
    }
    
    func getUsersRef() -> Firebase {
        
        let baseString = getBaseUrl() as String
        
        let usersRefString = baseString + "/users"
        
        let usersRef = Firebase(url: usersRefString)
        
        return usersRef
        
    }
    
    //MARK: method to create new user
    
    func createPerson(emailString : String, passwordString: String, firstNameString: String, lastNameString: String, uid: String){
        
        let person = Person.init(firstName: firstNameString, lastName: lastNameString, email: emailString, password: passwordString, uid: uid)
        
        if let lastLocation = self.temporaryLastLocation {
            
            person.lastLocation = lastLocation
            
        } else {
            
            print("location has not yet been set")
            
        }
        
        let personDictionary = convertPersonIntoDictionary(person)
        
        createPersonDictionaryOnFireBase(personDictionary)
        
    }
    
    //MARK: method to authenticate user
    
    func authenticateUserWithEmailAndPassword(email : String, password: String){
        
        let usersRef = getUsersRef()
        
        usersRef.authUser(email, password: password) { (error, authData) -> Void in
            
            if (error != nil) {
               
                print(error.localizedDescription)
                
            } else {
                
                let userRef = usersRef.childByAppendingPath(authData.uid)
                
                userRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
                    
                    if let personDictionary = snapshot.value {
                        
                        self.currentPerson = Person.init(dictionary: personDictionary as! [String : AnyObject])
                        
                        if let lastLocation = self.temporaryLastLocation {
                            
                            // NEEDS FIX: not sure I should be force unwrapping here but I just created current person so this should be good to go
                            self.currentPerson!.lastLocation = lastLocation
                            
                        } else {
                            
                            print("location has not yet been set")
                            
                        }
                        
                        print(self.currentPerson)
                    }
                    
                })
            
                
            }
            
        }

        
        
    }
    
    //MARK: create person Dictionary in Firebase
    
    func createPersonDictionaryOnFireBase(dictionary : [String : AnyObject]) {
        
        let usersRef = getUsersRef()
        
        let uidString = dictionary["uid"] as! String
        
        let newUserRef = usersRef.childByAppendingPath(uidString)
        
        newUserRef.setValue(dictionary)
    }
    
    //MARK: convert and update person into dictionary
    
    func savePersonIntoDictionary(person : Person) -> Void {
        
         let personDictionary = convertPersonIntoDictionary(person)
        
         updatePersonDictionaryInFirebase(personDictionary)
        
    }
    
    
    //MARK: update person Dictionary in Firebase
    
    func updatePersonDictionaryInFirebase(dictionary : [String : AnyObject]) -> Void {
        
        let usersRef = getUsersRef()
        
        let uidString = dictionary["uid"] as! String
        
        let userRef = usersRef.childByAppendingPath(uidString)
        
        userRef.updateChildValues(dictionary)
        
    }
    
   
    
    //MARK: convert person object into dictionary
    
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
        
        dictionary["uid"] = person.uid
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
