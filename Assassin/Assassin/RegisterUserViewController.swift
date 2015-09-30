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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navController = navigationController {
            
            navController.navigationBarHidden = false
        }
    }
    
    //MARK: textfield checking methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        warningLabel.text = ""
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == firstNameTextField || textField == lastNameTextField {
            
            if controlTestForNamesAndPasswordTextFields(textField, andCharacterCountGreaterThan: 0) && (string != "") || controlTestForNamesAndPasswordTextFields(textField, andCharacterCountGreaterThan: 2) && (string == "") {
                
                warningLabel.text = ""
                
                if controlTestForNamesAndPasswordTextFields(firstNameTextField, andCharacterCountGreaterThan: 1) &&
                    controlTestForNamesAndPasswordTextFields(lastNameTextField, andCharacterCountGreaterThan: 1) &&
                    controlTestForNamesAndPasswordTextFields(passwordTextField, andCharacterCountGreaterThan: 4) &&
                    controlTestForConfirmPasswordTextField(confirmPasswordTextField) &&
                    controlTestForEmailTextField(emailTextField, andCharacterCountGreaterThan: 5) {
                    
                    registerButton.enabled = true
                        
                } else {
                    registerButton.enabled = false
                }
                
            } else {
                registerButton.enabled = false
            }
        }
        
        if textField == passwordTextField {
            
            if controlTestForNamesAndPasswordTextFields(textField, andCharacterCountGreaterThan: 3) && (string != "") || controlTestForNamesAndPasswordTextFields(textField, andCharacterCountGreaterThan: 5) && (string == "") {
                
                warningLabel.text = ""
                
                if controlTestForNamesAndPasswordTextFields(firstNameTextField, andCharacterCountGreaterThan: 1) &&
                    controlTestForNamesAndPasswordTextFields(lastNameTextField, andCharacterCountGreaterThan: 1) &&
                    controlTestForConfirmPasswordTextField(confirmPasswordTextField) &&
                    controlTestForEmailTextField(emailTextField, andCharacterCountGreaterThan: 5) {
                        
                        registerButton.enabled = true
                        
                } else {
                    registerButton.enabled = false
                }
                
            } else {
                registerButton.enabled = false
            }
        }
        
        if textField == emailTextField {
            
            if controlTestForEmailTextField(textField, andCharacterCountGreaterThan: 4) && (string != "") ||
                controlTestForEmailTextField(textField, andCharacterCountGreaterThan: 6) && (string == "") {
                
                warningLabel.text = ""
                
                if controlTestForNamesAndPasswordTextFields(firstNameTextField, andCharacterCountGreaterThan: 1) &&
                    controlTestForNamesAndPasswordTextFields(lastNameTextField, andCharacterCountGreaterThan: 1) &&
                    controlTestForNamesAndPasswordTextFields(passwordTextField, andCharacterCountGreaterThan: 4) &&
                    controlTestForConfirmPasswordTextField(confirmPasswordTextField) {
                        
                        registerButton.enabled = true
                        
                } else {
                    registerButton.enabled = false
                }
                
            } else {
                registerButton.enabled = false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == firstNameTextField {
            textField.resignFirstResponder()
            lastNameTextField.becomeFirstResponder()
        }
        if textField == lastNameTextField {
            textField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        }
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            textField.resignFirstResponder()
            confirmPasswordTextField.becomeFirstResponder()
        }
        if textField == confirmPasswordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        
        if textField == firstNameTextField {
            
            if controlTestForNamesAndPasswordTextFields(textField, andCharacterCountGreaterThan: 1) {
                return true
                
            } else {
                warningLabel.text = "First name must be more than one letter."
                return false
            }
        }
        if textField == lastNameTextField {
            
            if controlTestForNamesAndPasswordTextFields(textField, andCharacterCountGreaterThan: 1) {
                return true
                
            } else {
                warningLabel.text = "Last name must be more than one letter."
                return false
            }
        }
        if textField == emailTextField {
            
            if controlTestForEmailTextField(textField, andCharacterCountGreaterThan: 5) {
                return true
                
            } else {
                warningLabel.text = "You must enter a valid email address."
                return false
            }
        }
        if textField == passwordTextField {
            
            if controlTestForNamesAndPasswordTextFields(textField, andCharacterCountGreaterThan: 4) {
                return true
                
            } else {
                warningLabel.text = "Password must be more than four characters."
                return false
            }
        }
        if textField == confirmPasswordTextField {
            
            if controlTestForConfirmPasswordTextField(textField) {
                return true
                
            } else {
                warningLabel.text = "Passwords must match."
                return false
            }
        }
        return true
    }
    
    //MARK: textfield control test methods
    
    func controlTestForNamesAndPasswordTextFields(textField: UITextField, andCharacterCountGreaterThan count: Int) -> Bool {
        
        if let typedText = textField.text {
            
            if typedText.characters.count > count {
                return true
            }
        }
        return false
    }
    
    func controlTestForEmailTextField(textField: UITextField, andCharacterCountGreaterThan count: Int) -> Bool {
        
        if let emailText = textField.text {
            
            if (emailText.containsString("@")) && (emailText.containsString(".")) && (emailText.characters.count > count) {
                return true
            }
        }
        return false
    }
    
    func controlTestForConfirmPasswordTextField(textField: UITextField) -> Bool {
        
        if let passwordText = passwordTextField.text, confirmPasswordText = textField.text {
            
            if (confirmPasswordText == passwordText) {
                registerButton.enabled = true
                return true
            }
        }
        return false
    }

    //MARK: register button method
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        
        if let emailString = emailTextField.text, passwordString = passwordTextField.text, firstNameString = firstNameTextField.text, lastNameString = lastNameTextField.text {
            
            registerActivityIndicator.startAnimating()

            registerUserWithEmailAndPassword(emailString, passwordString: passwordString, firstNameString: firstNameString, lastNameString: lastNameString)
            
        } else {
            
            warningLabel.text = "Must enter email and password"
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
                print("Created user account with uid: \(uid)")
                
                if let uid = uid {
                
                FirebaseNetworkController.sharedInstance.createPerson(emailString, passwordString: passwordString, firstNameString: firstNameString, lastNameString: lastNameString, uid: uid)
             
                self.transitionToNextView()
                
                }
            }
        })
        
    }
    
    //MARK: segue method
    
    func transitionToNextView() -> Void {
        
      self.performSegueWithIdentifier("presentTabBarFromRegistration", sender: self)
        
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
