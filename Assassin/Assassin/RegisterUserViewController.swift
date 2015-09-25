//
//  RegisterUserViewController.swift
//  Assassin
//
//  Created by Michael Sacks on 9/14/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit
import Firebase

class RegisterUserViewController: UIViewController {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        
        
     if passwordTextField.text != confirmPasswordTextField.text {
            
            warningLabel.text = "Passwords must match"
            
        } else if emailTextField.text?.containsString("@") == false {
            //TODO: Better way to check email?
            warningLabel.text = "Must enter a valid email"
            
        } else {
        
            warningLabel.text = ""
            
            if let emailString = emailTextField.text, passwordString = passwordTextField.text, firstNameString = firstNameTextField.text, lastNameString = lastNameTextField.text {
                
               registerUserWithEmailAndPassword(emailString, passwordString: passwordString, firstNameString: firstNameString, lastNameString: lastNameString)
                
                
            } else {
                
                warningLabel.text = "Must enter email and password"
                
            }
        }
    }

    
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
