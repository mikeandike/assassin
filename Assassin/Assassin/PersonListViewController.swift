//
//  PersonListViewController.swift
//  Assassin
//
//  Created by Michael Sacks on 9/14/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit

class PersonListViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let refreshUsersNearbyControl = UIRefreshControl.init()

    let personCellID = "personCellID"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshUsersNearbyControl.backgroundColor = AppearenceController.purpleColor
        refreshUsersNearbyControl.tintColor = UIColor.whiteColor()
        refreshUsersNearbyControl.addTarget(self, action: "refreshNearbyUsersTapped", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshUsersNearbyControl)
        
        // Do any additional setup after loading the view.
    }
    
    func refreshNearbyUsersTapped(){
        
        tableView.reloadData()
        
        refreshUsersNearbyControl.endRefreshing()
        
    }
    
    
    @IBAction func starButtonTapped(sender: UIButton) {
        
       let cell = sender.superview!.superview! as! PersonTableViewCell
        
        if let indexPath = tableView.indexPathForCell(cell) {
        
            let starredPerson = FirebaseNetworkController.sharedInstance.peopleNearby[indexPath.row]
            FirebaseNetworkController.sharedInstance.setStarUser(starredPerson.uid)

        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: tableview delegate methods
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 44
        
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
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if FirebaseNetworkController.sharedInstance.peopleNearby.count >= 1 {
            
            if let timeAtLastLocation = FirebaseNetworkController.sharedInstance.currentPerson?.timeAtLastLocation {
                
                let lastRefreshedString = FirebaseNetworkController.sharedInstance.convertDateIntoString(timeAtLastLocation)
                
                return "Last refreshed at \(lastRefreshedString)"
                
            } else {
                
                print("There's not a current user")
                
                return ""
                
            }
            
        } else {
            
            return "No users nearby. Swipe down to refresh"
            
        }
        
    }
    
    
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
        
        if(person.uid == FirebaseNetworkController.sharedInstance.starredStrings[i]) {
            
        }
        
        cell.nameLabel.text = person.firstName + " " + person.lastName
        cell.nameLabel.font = AppearenceController.bigText
    
        cell.companyLabel.text = person.company
        cell.companyLabel.font = AppearenceController.mediumBigText
        cell.jobTitleLabel.text = person.jobTitle
        cell.jobTitleLabel.font = AppearenceController.mediumSmallText
        
        
        return cell
    }
    
}

extension PersonListViewController : UITabBarControllerDelegate {
    
    @objc func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        var navController = viewController as! UINavigationController;
            navController.
        }
        
        if viewController.isKindOfClass(UINavigationController) {
            self.tableView.reloadData()
        }
    }
    
}