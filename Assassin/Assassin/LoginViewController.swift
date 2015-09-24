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
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //go ahead and start getting location
        
        LocationController.sharedInstance.getLocation()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.enabled = true
        warningLabel.text = ""
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        warningLabel.text = ""
        loginButton.enabled = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == usernameTextField {
            
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }
        
        if textField == passwordTextField {
            
            textField.resignFirstResponder()
//            loginButtonTapped(loginButton)
        }
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        if textField == usernameTextField {
            if let emailText = textField.text {
                
                if (emailText.containsString("@") == false) || (emailText.containsString(".") == false) || (emailText.characters.count < 6) {
                    
                    warningLabel.text = "You must enter a valid email address."
                    return false
                }
            }
        }
        if textField == passwordTextField {
            if let passwordText = textField.text {
                
                if passwordText.characters.count < 5 {
                    
                    warningLabel.text = "Password must be at least 5 characters."
                    return false
                    
                } else {
                    loginButton.enabled = true
                    loginButtonTapped(loginButton)
                }
            }
        }
        return true
    }

    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        if let emailString = usernameTextField.text, passwordString = passwordTextField.text {
            
            loginUser(emailString, password: passwordString)
            
        } else {
            
            warningLabel.text = "Invalid Email or Password"
            
        }
        
    }
    
    //MARK: login user
    
    func loginUser(username : String, password: String) -> Void {
        
        FirebaseNetworkController.sharedInstance.authenticateUserWithEmailAndPassword(username, password: password)
        
        transitionToNextView()
                
    }
    
    func transitionToNextView() -> Void {
        
        self.performSegueWithIdentifier("loginAndPresentTabBar", sender: self)
        
    }
    
    //MARK: get location methods
    
    func getLocation() {
       
        let locationController = LocationController()
        locationController.getLocation()
        
    }
    
   
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
