//
//  PersonListViewController.swift
//  Assassin
//
//  Created by Michael Sacks on 9/14/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit

class PersonListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let personCellID = "personCellID"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func starButtonTapped(sender: UIButton) {
        
       let cell = sender.superview!.superview! as! PersonTableViewCell
        
        if let indexPath = tableView.indexPathForCell(cell) {
        
            let starredPerson = FirebaseNetworkController.sharedInstance.peopleNearby[indexPath.row]
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "presentDetailViewFromCell" {
            
            let destinationVC = segue.destinationViewController as! PersonDetailViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
        
                let person = FirebaseNetworkController.sharedInstance.peopleNearby[indexPath.row]
                
                    destinationVC.person = person
                    destinationVC.isCurrentUsersProfile = false
            }
            
        } else if segue.identifier == "presentCurrentUserProfile" {
            
            let destinationVC = segue.destinationViewController as! PersonDetailViewController
            
            if let person = FirebaseNetworkController.sharedInstance.currentPerson {
                
                destinationVC.person = person
                destinationVC.isCurrentUsersProfile = true
                
            }
            
            
        }
        
    }
        
}



extension PersonListViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FirebaseNetworkController.sharedInstance.peopleNearby.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(personCellID, forIndexPath: indexPath) as! PersonTableViewCell
        
        let person = FirebaseNetworkController.sharedInstance.peopleNearby[indexPath.row]
        
        if let image = person.image {
            cell.userImageView.image = image

        } else {
            cell.userImageView.image = UIImage(named: "blankProfileGray")
        }
        
        cell.nameLabel.text = person.firstName + " " + person.lastName
    
        cell.companyLabel.text = person.company
        cell.jobTitleLabel.text = person.jobTitle
        
        return cell
    }
    
}

