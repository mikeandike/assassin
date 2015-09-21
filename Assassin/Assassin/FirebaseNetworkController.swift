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
    
    var peopleNearby : [Person] = []
    var currentPerson: Person?
    
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
        
        self.currentPerson = person
        
        let personDictionary = convertPersonIntoDictionary(person)
        
        createPersonDictionaryOnFireBase(personDictionary)
        
        let userExistsNotification = NSNotificationCenter.defaultCenter().postNotificationName("userExistsNotification", object: nil)
        
        
        
        
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
                        
                        let userExistsNotification = NSNotificationCenter.defaultCenter().postNotificationName("userExistsNotification", object: nil)
                        
                    }
                    
                })
            
                
            }
            
        }

        
        
    }
    
    //MARK: Add nearby user to array of people nearby
    
    func addPersonWithUIDAndLocationToPeopleNearby(uid : String, location: CLLocation) {
        
        let usersRef = getUsersRef()
        
        let userRef = usersRef.childByAppendingPath(uid)
        
        userRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
            
            if let personDictionary = snapshot.value {
                
                let person : Person = Person.init(dictionary: personDictionary as! [String : AnyObject])
                
                person.lastLocation = location
                
                self.peopleNearby.append(person)
                
            }
        });
        
    }
    
    //MARK: method to remove person from dictionary
    
    func removePersonWithUIDFromPeopleNearby(uid : String) {
        
        let foundPerson = self.peopleNearby.filter{ $0.uid == uid }.first
        
        if let person = foundPerson {
            
            let index = self.peopleNearby.indexOf(person)
            
            if let personIndex = index {
                
                self.peopleNearby.removeAtIndex(personIndex)
                
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
