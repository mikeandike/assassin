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
        
        NSNotificationCenter.defaultCenter().postNotificationName("userExistsNotification", object: nil)
        
        
        
        
    }
    
    //MARK: method to authenticate user
    
    func authenticateUserWithEmailAndPassword(email : String, password: String, completion: (Bool) -> ()){
        
            let usersRef = getUsersRef()
            
            usersRef.authUser(email, password: password) { (error, authData) in
                
                // TODO: change to if (error) ??
                if (error != nil) {
                    
                    print(error.localizedDescription)
                    
                    completion(false)
                    
                } else {
                    
                    let userRef = usersRef.childByAppendingPath(authData.uid)
                    
                    userRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
                        
                        if let personDictionary = snapshot.value {
                            
                            self.currentPerson = Person.init(dictionary: personDictionary as! [String : AnyObject])
                            
                            NSNotificationCenter.defaultCenter().postNotificationName("userExistsNotification", object: nil)
                            
                            completion(true)
                        } else {
                            completion(false)
                        }
                        
                    })
                    
                    
                }
                
            }
            
        
        
        
        
    }
    
    //MARK: Add nearby user to array of people nearby
    
    func addPersonWithUIDAndLocationToPeopleNearby(uid : String, location: CLLocation, locationOfCurrentUser: CLLocation) {
        
        //If the location is not the location that was queried from
        if location.coordinate.latitude != locationOfCurrentUser.coordinate.latitude || location.coordinate.longitude != locationOfCurrentUser.coordinate.longitude {
    
            let usersRef = getUsersRef()
            
            let userRef = usersRef.childByAppendingPath(uid)
            
            userRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
                
                if let personDictionary = snapshot.value {
                    
                    let person : Person = Person.init(dictionary: personDictionary as! [String : AnyObject])
                    
                    person.lastLocation = location
                    
                    self.peopleNearby.append(person)
                    
                    print("peopleNearby: \(self.peopleNearby)")
                    
                }
            });
            
        }
        
    }
    
    //MARK: method to remove person from dictionary
    
    func removePersonWithUIDFromPeopleNearby(uid : String) {
        
        let foundPerson = self.peopleNearby.filter{ $0.uid == uid }.first
        
        if let person = foundPerson {
            
            let index = self.peopleNearby.indexOf(person)
            
            if let personIndex = index {
                
                self.peopleNearby.removeAtIndex(personIndex)
                
                print("peopleNearby: \(self.peopleNearby)")
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
        dictionary["bio"] = person.bio
        dictionary["purpose"] = person.purpose
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
    

//MARK: Convert person.timestamp into useable timestring
    
    func convertDateIntoString(date : NSDate) -> String {
        
        let currentCalendar = NSCalendar.currentCalendar()
            
        let dateComponents = currentCalendar.components([NSCalendarUnit.Minute, NSCalendarUnit.Hour], fromDate: date)
            
        
        let dateFormatter = NSDateFormatter.init()
        
            var minuteString = ""
            
            if dateComponents.minute < 10 {
                
                minuteString = "0\(dateComponents.minute)"
                
            } else {
            
                minuteString = "\(dateComponents.minute)"
            
            }
            
            var hourString = ""
            var AMPMString = ""
            
            if dateComponents.hour > 11 {
                
                //if its noon
                if dateComponents.hour == 12 {
                    
                   hourString = "\(dateComponents.hour)"
                   AMPMString = dateFormatter.PMSymbol
                    
                } else {
                    //its 1pm or later
                    
                    hourString = "\(dateComponents.hour - 12)"
                    AMPMString = dateFormatter.PMSymbol
                    
                }
                
            } else {
                //its the am
                
                if dateComponents.hour == 0 {
                    
                    hourString = "12"
                    AMPMString = dateFormatter.AMSymbol
                    
                } else {
                    
                    hourString = "\(dateComponents.hour)"
                    AMPMString = dateFormatter.AMSymbol
                    
                }
                
            }
            
           let timeString = "\(hourString):\(minuteString)\(AMPMString)"
            
    
    return timeString
        
    }
   

}
