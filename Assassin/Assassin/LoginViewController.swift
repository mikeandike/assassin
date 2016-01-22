//
//  LoginViewController.swift
//  Assassin
//
//  Created by Michael Sacks on 9/14/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginAttemptActivityIndicator: UIActivityIndicatorView!
    
    var hasUsersNearby = false
    
    var hasCurrentUser = false
    
    var hasStarredUsers = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register to be notified when first query of users nearby comes back and when starred users come back
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "usersNearbyQueryFinished", name: "usersNearbyQueryFinishedNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "starredUsersArrived", name: "starredUsersExistNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentLocationUnavailableAlert", name: "locationUnavailable", object: nil)
        
        loadLogin()
        
        // Do any additional setup after loading the view.
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            
            let locationServicesExplanationAlert = UIAlertController(title: "Allowing Location Services", message: "IntroScope only works if you enable location services. It does not track or save or share your location. It uses your location to show you other users near you, but it only uses your location while you have the app running. You can change this setting at any time in your device's Settings.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Next", style: .Default, handler: { (nextAction) -> Void in
                
                LocationController.sharedInstance.getLocation()
            })
            locationServicesExplanationAlert.addAction(okAction)
            presentViewController(locationServicesExplanationAlert, animated: true, completion: nil)
            
        } else if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            LocationController.sharedInstance.getLocation()
        }
        
        //Appearence related activities
        
        AppearenceController.initializeAppearence()
        warningLabel.textColor = AppearenceController.tealColor
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        warningLabel.text = ""
        warningLabel.numberOfLines = 0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navController = navigationController {
            
            navController.navigationBarHidden = true
        }
    }
    
    func presentLocationUnavailableAlert(notification: NSNotification) {
        
        var message = ""
        if let messageString = notification.object as? String {
            message = messageString
        } else {
            message = "error with location services"
        }
        
        let locationServicesAlert = UIAlertController(title: "Attention:", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        locationServicesAlert.addAction(okAction)
        presentViewController(locationServicesAlert, animated: true, completion: nil)
    }
    
    //MARK: textfield delegate - textfield checking methods
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        warningLabel.text = ""
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()

        if textField == emailTextField {
            
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            
            if controlTestForEmailTextField() {
                warningLabel.text = ""
                
            } else {
                warningLabel.text = "You must enter a valid email address."
            }
        }
        
        if textField == passwordTextField {
            
            if controlTestForPasswordTextField() {
                warningLabel.text = ""
                
            } else {
                warningLabel.text = "Password must be more than 4 characters."
            }
        }
        return true
    }
    
    //MARK: text field checking control test methods
    
    func controlTestForEmailTextField() -> Bool {
        
        if let emailText = emailTextField.text {
            
            if (emailText.containsString("@")) && (emailText.containsString(".")) && (emailText.characters.count > 5) {
                return true
            }
        }
        return false
    }
    
    func controlTestForPasswordTextField() -> Bool {
        
        if let passwordText = passwordTextField.text {
            
            if (passwordText.characters.count > 4) {
                return true
            }
        }
        return false
    }
    
    //MARK: login button method
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        saveLogin()
        loginButton.enabled = false
        
        if let emailString = emailTextField.text, passwordString = passwordTextField.text {
            
            loginAttemptActivityIndicator.startAnimating()
            loginUser(emailString, password: passwordString)
            
        } else {
            warningLabel.text = "Must have Email and Password"
            loginButton.enabled = true
        }
    }
    
    //MARK: users nearby query finished
    
    func usersNearbyQueryFinished() {
        
        hasUsersNearby = true
        transitionToNextView()
    }
    
    func currentUserArrived() {
        
        hasCurrentUser = true
        transitionToNextView()
    }
    
    func starredUsersArrived() {
        
        hasStarredUsers = true
        transitionToNextView()
    }
    
    //MARK: login user
    
    func loginUser(username : String, password: String) -> Void {
        
        FirebaseNetworkController.sharedInstance.authenticateUserWithEmailAndPassword(username, password: password) { (hasUser) -> () in
            
            if hasUser {
                self.currentUserArrived()
                
            } else {
                print("authenticate user failed")
                self.warningLabel.text = "Login failed. Email or password may be wrong. Please try again."
                self.loginAttemptActivityIndicator.stopAnimating()
                self.loginButton.enabled = true
            }
        }
    }
    
    func transitionToNextView() -> Void {
        
        if hasCurrentUser == true && hasStarredUsers == true && hasUsersNearby == true {
            
            self.performSegueWithIdentifier("loginAndPresentPeople", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        //set the static copy here, right before we present the view
        
        if segue.identifier == "loginAndPresentPeople" {
            
            if let personListVC = segue.destinationViewController as? PersonListViewController {
                
                personListVC.peopleNearbyStaticCopy = FirebaseNetworkController.sharedInstance.peopleNearby
            }
        }
    }
        
    //MARK: remember credentials - NSUserDefaults methods
    
    func saveLogin() {
        
        FirebaseNetworkController.sharedInstance.saveLoginToUserDefaults(emailTextField.text, password: passwordTextField.text)
    }
    
    func loadLogin() {
        
        let loginArray = FirebaseNetworkController.sharedInstance.fetchLoginFromUserDefaults()
            emailTextField.text = loginArray[0]
            passwordTextField.text = loginArray[1]
    }
    
    //MARK: memory warning method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

