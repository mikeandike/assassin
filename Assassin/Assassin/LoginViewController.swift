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
    @IBOutlet weak var boringActivityIndicator: UIActivityIndicatorView!
    
    var hasUsersNearby : Bool = false
    
    var hasCurrentUser: Bool = false

    var hasStarredUsers : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register to be notified when first query of users nearby comes back and when starred users come back
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "usersNearbyQueryFinished", name: "usersNearbyQueryFinishedNotification", object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "starredUsersArrived", name: "starredUsersExistNotification", object: nil)
    
        
        loadLoginFromDefaults()

        // Do any additional setup after loading the view.
        
        //go ahead and start getting location
        
        LocationController.sharedInstance.getLocation()
        
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
    
    
    
    //MARK: textfield delegate - textfield checking methods
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        warningLabel.text = ""
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }
        
        if textField == passwordTextField {
            
            textField.resignFirstResponder()
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
        
        saveLoginToDefaults()
        
        loginButton.enabled = false
        
        if let emailString = emailTextField.text, passwordString = passwordTextField.text {
            
            boringActivityIndicator.startAnimating()
            
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
    
                print("transitioning to new view")
//                self.transitionToNextView()
                self.currentUserArrived()
//                self.boringActivityIndicator.stopAnimating()
                
            } else {
                print("authenticate user failed")
                self.warningLabel.text = "Login failed. Email does not exist, or password is incorrect."
                self.boringActivityIndicator.stopAnimating()
                
                self.loginButton.enabled = true
            }
        }
    }
    
    func transitionToNextView() -> Void {
        
        
        if hasCurrentUser == true  {

            if hasStarredUsers == true {
                
                if hasUsersNearby == true {
                    
                         self.performSegueWithIdentifier("loginAndPresentTabBar", sender: self)
                    }

                }
            
           
            
        }
        
    }
    
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    //set the static copy here, right before we present the view
    
        if segue.identifier == "loginAndPresentTabBar" {
            
            if let personListVC = segue.destinationViewController as? PersonListViewController {
            
            personListVC.peopleNearbyStaticCopy = FirebaseNetworkController.sharedInstance.peopleNearby
                
            }
            
        }
        
    }
    
    //MARK: get location methods
    
    func getLocation() {
       
        let locationController = LocationController()
        locationController.getLocation()
        
    }
    
    //MARK: remember credentials - NSUserDefaults methods
    
    func saveLoginToDefaults() {
        
        var loginArray = [String]()
        
        if let emailToSave = emailTextField.text {
            
            loginArray.insert(emailToSave, atIndex: 0)
            
        } else {
            loginArray.insert("", atIndex: 0)
        }
        
        if let passwordToSave = passwordTextField.text {
            
            loginArray.insert(passwordToSave, atIndex: 1)
            
        } else {
            loginArray.insert("", atIndex: 1)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(loginArray, forKey: "savedLogin")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func loadLoginFromDefaults() {
        
        
        
        if let loginArray = NSUserDefaults.standardUserDefaults().stringArrayForKey("savedLogin") {
            
            emailTextField.text = loginArray[0]
            passwordTextField.text = loginArray[1]
        }
    }
    
    //MARK: memory warning method

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
