//
//  LoginViewController.swift
//  Assassin
//
//  Created by Michael Sacks on 9/14/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        if let emailString = usernameTextField.text, passwordString = passwordTextField.text {
            
            loginUser(emailString, password: passwordString)
            
        } else {
            
            warningLabel.text = "Invalid Email or Password"
            
        }
        
    }
    
    func loginUser(username : String, password: String) -> Void {
        
        let ref = Firebase(url: FirebaseNetworkController.getBaseUrl() as String)
        
        ref.authUser(username as String, password: password as String) {
            error, authData in
            if error != nil {
                
                self.warningLabel.text = "Error: \(error.localizedDescription)"
                
            } else {
                // user is logged in, check authData for data
                self.transitionToNextView()
                
            }
        }
        
    }
    
    func transitionToNextView() -> Void {
        
        self.performSegueWithIdentifier("loginAndPresentTabBar", sender: self)
        
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
