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
    var currentPerson : Person?
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
                    
                    //start getting your starred users here
                    self.loadStarredUsersForCurrentUserWithUID(authData.uid)
                    
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
                       // self.loadStarredUserWithUid(authData.uid)
                    })
                    
                    
                }
                
            }
        
    }
    
    //MARK: Add nearby user to array of people nearby
    
    func addPersonWithUIDAndLocationToPeopleNearby(uid : String, location: CLLocation, locationOfCurrentUser: CLLocation) {
        
        //If the location is not the location that was queried from
        if location.coordinate.latitude != locationOfCurrentUser.coordinate.latitude || location.coordinate.longitude != locationOfCurrentUser.coordinate.longitude {
            
            let repeatPerson = self.peopleNearby.filter{ $0.uid == uid }.first

            if let personWhoAlreadyExists = repeatPerson {
                
                print("\(personWhoAlreadyExists) already exists ey")
                
            } else {
                
            //The person isn't already in the array so add them
    
                let usersRef = getUsersRef()
            
                let userRef = usersRef.childByAppendingPath(uid)
            
                userRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
                
                    if let personDictionary = snapshot.value {
                    //print(snapshot.value)
                        let person : Person = Person.init(dictionary: personDictionary as! [String : AnyObject])
                    
                        person.lastLocation = location
                    
                        self.peopleNearby.append(person)

                        //TODO: add a method here checking to see if the person is on the stars array, if so mark them as starred
                        //TODO: we have to make sure the that we have a current user and a list of starred user strings before we query users nearby for this to work
                    
                        print("peopleNearby: \(self.peopleNearby)")
                    
                    }
                });
            
            }
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
        dictionary["lastLocation"] = lastLocationDictionary
        dictionary["imageString"] = imageString
    
        return dictionary
        
    }
    
    //MARK: save starred users UIDS
    
   
    

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
        
        let usersRef = getUsersRef()
        
        if let currentPerson = self.currentPerson {
            
            //add the UID to their starred UIDS
            currentPerson.starredUsersUIDS.append(personToStar.uid)
            
            //add the person to the starredUsers
            
            starredPeople.append(personToStar)
            
            //save the that uid to the starred users dictionary on firebase
            //will this add a new uid or only update an old one?
            
            //Saving a unique value as a dictionary entry with both the key and the value as the uid is the best way to save an array on Firebase according to Matt and a random blog post I read - Michelle
            usersRef.childByAppendingPath(currentPerson.uid).childByAppendingPath("starredUsersUIDS").updateChildValues([personToStar.uid : personToStar.uid])
            //            self.starredStrings.append(starUID)
            //            self.loadStarredUserWithUid(starUID)
        }
    }
    
    func deleteStarredUserWithUID(UID : String){
        
        //delete from starred people array on firebase
        
        let userToDelete = starredPeople.filter{ $0.uid == UID }.first
        
        if let foundUserToDelete = userToDelete {
            
            if let index = starredPeople.indexOf(foundUserToDelete) {
            
            starredPeople.removeAtIndex(index)
                
            }
            
        }
        
    
        //delete from current users firebase array
        if let currentUser = currentPerson {
        
            let UIDToDelete = currentUser.starredUsersUIDS.filter{ $0 == UID }.first
            
            if let foundUIDToDelete = UIDToDelete {
                
                if let index = currentUser.starredUsersUIDS.indexOf(foundUIDToDelete) {
                
                currentUser.starredUsersUIDS.removeAtIndex(index)
                    
                }
                
            }
            
        }
    
        saveCurrentUsersStarredUIDSToFirebase()
        
    }
    
    // this method deletes the current starredUsersUIDS array for the current user and resaves the entire array
    
    func saveCurrentUsersStarredUIDSToFirebase() {
        
        //save that current users starred users array to firebase by deleting the only one and adding a new one
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
            
            print(snapshot.value)
            
            //Set snapshot.value to array of stared users
            if let snapshotValue = snapshot.value {
                
                let starredUserDictionary  = snapshotValue
                
                if let currentUser : Person = self.currentPerson {
                        
//                        let starredUsersUIDS : [String] = starredUserDictionary.allKeys
                    
//                        currentUser.starredUsersUIDS = starredUsersUIDS
                    
                    if let starredUserDictAllKeys = starredUserDictionary.allKeys {
                        
                        print(starredUserDictAllKeys)
                        
                        for key in starredUserDictAllKeys {
                            
                            if let UIDString = key as? String {
                        
                                currentUser.starredUsersUIDS.append(UIDString)
                                
                            }
                            
                        }
                        
                        for starredUID : String in currentUser.starredUsersUIDS {
                            
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
//                
//
            }
//
//            }, withCancelBlock: { error in
//                print(error.description)
        })
        
    }
   
    
    
   
    
    func getStarredUserWithUidFromFirebase (uid : String) {
        
        let userRef = getUsersRef()
        
        userRef.childByAppendingPath(uid).observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
            if let personDictionary = snapshot.value {
                
                print(snapshot.value)
                let person : Person = Person.init(dictionary: personDictionary as! [String : AnyObject])
                
                self.starredPeople.append(person)
            
                print("starredPeople: \(self.starredPeople)")
                
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
        
        let timeString = "\(hourString):\(minuteString)\(AMPMString)"
        
        
        return timeString
        
    }

}
