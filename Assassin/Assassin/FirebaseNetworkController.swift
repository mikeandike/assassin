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
    
    var currentPerson : Person?
    var peopleNearby : [Person] = []
    var starredPeople : [Person] = []
    
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
        usersRef.authUser(email, password: password) { (error, authData) -> Void in
            // TODO: change to if (error) ??
            if (error != nil) {
                
                print(error.localizedDescription)
                completion(false)
                
            } else {
                //if the person logging in is in the peopleNearbyArray, remove them
                
                let selfInPeopleNearby = self.peopleNearby.filter{$0.uid == authData.uid}.first
                
                if let foundSelf = selfInPeopleNearby {
                    
                    if let index = self.peopleNearby.indexOf(foundSelf) {
                        
                        self.peopleNearby.removeAtIndex(index)
                    }
                }
                
                let userRef = usersRef.childByAppendingPath(authData.uid)
                
                userRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
                    
                    if let personDictionary = snapshot.value {
                        
                        self.currentPerson = Person.init(dictionary: personDictionary as! [String : AnyObject])
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("userExistsNotification", object: nil)
                        
                        self.loadStarredUsersForCurrentUserWithUID(self.currentPerson!.uid)
                        
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
        
        let usersRef = getUsersRef()
        let userRef = usersRef.childByAppendingPath(uid)
        
        userRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
            
            // we get an error here because we sometimes (i think) still go into this even if the snapshot.value is null
            if let personDictionary = snapshot.value {
                
                let person : Person = Person.init(dictionary: personDictionary as! [String : AnyObject])
                
                person.lastLocation = location
                
                let repeatPerson = self.peopleNearby.filter{ $0.uid == uid }.first
                
                //If the person to add doesn't already exist in the people nearby array
                
                if repeatPerson != nil {
                    return
                }
                
                //if the person nearby is the current user
                
                if let currentUser = self.currentPerson {
                    
                    if currentUser.uid == uid {
                        return
                    }
                }
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
        dictionary["bio"] = person.bio
        dictionary["purpose"] = person.purpose
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
    
    //MARK: starred user methods
    
    //this method adds the one uid to the starredUsersUIDs array of the current user on firebase
    
    func starPersonWithUID (personToStar : Person) {
        
        if let currentUser = currentPerson {
            
            let existingStarredUser = currentUser.starredUsersUIDS.filter{$0 == personToStar.uid}.first
            
            if existingStarredUser != nil {
                
                return
            }
        }
        
        let usersRef = getUsersRef()
        
        if let currentPerson = currentPerson {
            
            //add the UID to their starred UIDS
            currentPerson.starredUsersUIDS.append(personToStar.uid)
            
            //don't need to add this person to starredPeople, because Firebase will observe a change made on the user, which calls load starredUsers again
            
            usersRef.childByAppendingPath(currentPerson.uid).childByAppendingPath("starredUsersUIDS").updateChildValues([personToStar.uid : personToStar.uid])
        }
    }
    
    func deleteStarredUserWithUID(uid : String){
        
        //delete from starred people array on firebase network controller
        
        let userToDelete = starredPeople.filter{ $0.uid == uid }.first
        
        if let foundUserToDelete = userToDelete {
            
            if let index = starredPeople.indexOf(foundUserToDelete) {
                
                starredPeople.removeAtIndex(index)
            }
        }
        
        //delete from current users starred users uids array
        if let currentUser = currentPerson {
            
            if let index = currentUser.starredUsersUIDS.indexOf(uid) {
                
                currentUser.starredUsersUIDS.removeAtIndex(index)
            }
        }
        //delete from current users firebase array by overwriting it with updated local array
        saveCurrentUsersStarredUIDSToFirebase()
    }
    
    func saveCurrentUsersStarredUIDSToFirebase() {
        
        let starredRef = getUsersRef()
        
        if let currentUser = self.currentPerson{
            
            var starDictionary : [String : AnyObject] = Dictionary<String, String>()
            
            for uidString in currentUser.starredUsersUIDS {
                
                starDictionary[uidString] = uidString
            }
            starredRef.childByAppendingPath(currentUser.uid).childByAppendingPath("starredUsersUIDS").setValue(starDictionary)
        }
    }
    
    func loadStarredUsersForCurrentUserWithUID(uid : String) {
        
        let userRef = getUsersRef()
        
        userRef.childByAppendingPath(uid).childByAppendingPath("starredUsersUIDS").observeSingleEventOfType(FEventType.Value, withBlock: {snapshot in
            
            if let snapshotValue = snapshot.value {
                
                let starredUserDictionary  = snapshotValue
                
                if let currentUser = self.currentPerson {
                    
                    if let starredUserDictAllKeys = starredUserDictionary.allKeys {
                        
                        for key in starredUserDictAllKeys {
                            
                            if let UIDString = key as? String {
                                
                                currentUser.starredUsersUIDS.append(UIDString)
                            }
                        }
                        
                        for starredUID in currentUser.starredUsersUIDS {
                            
                            self.getStarredUserWithUidFromFirebase(starredUID)
                        }
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("starredUsersExistNotification", object: nil)
                        
                    } else {
                        print("no keys")
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("starredUsersExistNotification", object: nil)
                    }
                    
                }
                
            } else {
                print("value is nil")
            }
        })
        
    }
    
    func getStarredUserWithUidFromFirebase (uid : String) {
        
        //check to prevent duplicates
        let existingStarredUser = starredPeople.filter{$0.uid == uid}.first
        
        if existingStarredUser != nil {
            return
        }
        
        let userRef = getUsersRef()
        
        userRef.childByAppendingPath(uid).observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
            
            if let personDictionary = snapshot.value {
                
                let person = Person.init(dictionary: personDictionary as! [String : AnyObject])
                
                person.isStarredUser = true
                
                self.starredPeople.append(person)
            }
        })
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
        
        let timeString = "\(hourString):\(minuteString) \(AMPMString)"
        
        return timeString
    }
}

