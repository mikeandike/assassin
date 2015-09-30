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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLoginFromDefaults()

        // Do any additional setup after loading the view.
        
        //go ahead and start getting location
        
        LocationController.sharedInstance.getLocation()
        
        //Appearence related activities
        
        AppearenceController.initializeAppearence()
        warningLabel.textColor = AppearenceController.tealColor
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.enabled = false
        warningLabel.text = ""
        warningLabel.numberOfLines = 0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navController = navigationController {
            
            navController.navigationBarHidden = true
        }
    }
    
    //MARK: text field checking methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        warningLabel.text = ""
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == emailTextField {
            
            if controlTestForEmailTextField(textField, andCharacterCountGreaterThan: 4) && (string != "") || controlTestForEmailTextField(textField, andCharacterCountGreaterThan: 6) && (string == "") {
                
                warningLabel.text = ""
                
                if controlTestForPasswordTextField(passwordTextField, andCharacterCountGreaterThan: 5) {
                    
                    loginButton.enabled = true
                    
                } else {
                    loginButton.enabled = false
                }
                
            } else {
                loginButton.enabled = false
            }
        }
        
        if textField == passwordTextField {
            
            if controlTestForPasswordTextField(textField, andCharacterCountGreaterThan: 3) && (string != "") || controlTestForPasswordTextField(textField, andCharacterCountGreaterThan: 5) && (string == "") {
                
                warningLabel.text = ""
                
                if controlTestForEmailTextField(emailTextField, andCharacterCountGreaterThan: 5) {
                    
                    loginButton.enabled = true
                    
                } else {
                    loginButton.enabled = false
                }
                
            } else {
                loginButton.enabled = false
            }
        }
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
            
            if controlTestForEmailTextField(textField, andCharacterCountGreaterThan: 5) {
                return true
                
            } else {
                warningLabel.text = "You must enter a valid email address."
                return false
            }
        }
        
        if textField == passwordTextField {
            
            if controlTestForPasswordTextField(textField, andCharacterCountGreaterThan: 4) {
                return true
                
            } else {
                warningLabel.text = "Password must be more than 4 characters."
                return false
            }
        }
        return true
    }
    
    //MARK: text field checking control test methods
    
    func controlTestForEmailTextField(textField: UITextField, andCharacterCountGreaterThan count: Int) -> Bool {
        
        if let emailText = textField.text {
            
            if (emailText.containsString("@")) && (emailText.containsString(".")) && (emailText.characters.count > count) {
                return true
            }
        }
        return false
    }
    
    func controlTestForPasswordTextField(textField: UITextField, andCharacterCountGreaterThan count: Int) -> Bool {
        
        if let passwordText = textField.text {
            
            if (passwordText.characters.count > count) {
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
            
        }
        
    }
    
    //MARK: login user
    
    func loginUser(username : String, password: String) -> Void {
        FirebaseNetworkController.sharedInstance.authenticateUserWithEmailAndPassword(username, password: password) { (hasUser) -> () in
            if hasUser {
                print("transitioning to new view")
                self.transitionToNextView()
            } else {
                print("authenticate user failed")
                self.warningLabel.text = "Login failed. Email does not exist, or password is incorrect."
                self.boringActivityIndicator.stopAnimating()
            }
        }
    }
    
    func transitionToNextView() -> Void {
        
        self.performSegueWithIdentifier("loginAndPresentTabBar", sender: self)
        
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
