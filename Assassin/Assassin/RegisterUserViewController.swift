//
//  RegisterUserViewController.swift
//  Assassin
//
//  Created by Michael Sacks on 9/14/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit
import Firebase

class RegisterUserViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Appearence related activities
        
        AppearenceController.initializeAppearence()
        warningLabel.textColor = AppearenceController.tealColor
        
        // Do any additional setup after loading the view.
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        warningLabel.text = ""
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentLocationUnavailableAlert:", name: "locationUnavailable", object: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navController = navigationController {
            
            navController.navigationBarHidden = false
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

        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        }
        if textField == lastNameTextField {
            emailTextField.becomeFirstResponder()
        }
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        if textField == firstNameTextField {
            
            if controlTestForNameTextFields(textField) {
                warningLabel.text = ""
                
            } else {
                warningLabel.text = "First name must be more than one letter."
            }
        }
        if textField == lastNameTextField {
            
            if controlTestForNameTextFields(textField) {
                warningLabel.text = ""
                
            } else {
                warningLabel.text = "Last name must be more than one letter."
            }
        }
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
                warningLabel.text = "Password must be more than four characters."
            }
        }
        if textField == confirmPasswordTextField {
            
            if controlTestForConfirmPasswordTextField() {
                warningLabel.text = ""
                
            } else {
                warningLabel.text = "Passwords must match."
            }
        }
        return true
    }
    
    //MARK: textfield control test methods
    
    func controlTestForNameTextFields(textField: UITextField) -> Bool {
        
        if let typedText = textField.text {
            
            if typedText.characters.count > 1 {
                return true
            }
        }
        return false
    }
    
    func controlTestForEmailTextField() -> Bool {
        
        if let emailText = emailTextField.text {
            
            if (emailText.containsString("@")) && (emailText.containsString(".")) && (emailText.characters.count > 5) {
                return true
            }
        }
        return false
    }
    
    func controlTestForPasswordTextField() -> Bool {
        
        if let typedText = passwordTextField.text {
            
            if typedText.characters.count > 4 {
                return true
            }
        }
        return false
    }
    
    func controlTestForConfirmPasswordTextField() -> Bool {
        
        if let passwordText = passwordTextField.text, confirmPasswordText = confirmPasswordTextField.text {
            
            if (confirmPasswordText == passwordText) {
                registerButton.enabled = true
                return true
            }
        }
        return false
    }
    
    //MARK: register button method
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        
        if controlTestForNameTextFields(firstNameTextField) && controlTestForNameTextFields(lastNameTextField) && controlTestForEmailTextField() && controlTestForPasswordTextField() && controlTestForConfirmPasswordTextField() {
            
            if let emailString = emailTextField.text, passwordString = passwordTextField.text, firstNameString = firstNameTextField.text, lastNameString = lastNameTextField.text {
                
                registerActivityIndicator.startAnimating()
                
                registerUserWithEmailAndPassword(emailString, passwordString: passwordString, firstNameString: firstNameString, lastNameString: lastNameString)
                
            } else {
                warningLabel.text = "One or more items is incomplete. Please check and try again."
            }
            
        } else {
            warningLabel.text = "Cannot register: please check your information and try again."
        }
    }
    
    //MARK: register user on firebase method
    
    func registerUserWithEmailAndPassword(emailString: String, passwordString: String, firstNameString: String, lastNameString: String) -> Void {
        
        let usersRef = FirebaseNetworkController.sharedInstance.getUsersRef()
        
        usersRef.createUser(emailString as String, password: passwordString as String, withValueCompletionBlock: { error, result in
            
            if error != nil {
                self.warningLabel.text = "Error registering user"
                
            } else {
                let uid = result["uid"] as? String
                
                if let uid = uid {
                    
                    FirebaseNetworkController.sharedInstance.createPerson(emailString, passwordString: passwordString, firstNameString: firstNameString, lastNameString: lastNameString, uid: uid)
                    self.transitionToNextView()
                }
            }
        })
    }
    
    //MARK: segue method
    
    func transitionToNextView() -> Void {
        
        self.performSegueWithIdentifier("presentPeopleFromRegistration", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

