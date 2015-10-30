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
    @IBOutlet weak var refreshFooterLabel: UILabel!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    let refreshUsersNearbyControl = UIRefreshControl.init()
    let personCellID = "personCellID"
    var peopleNearbyStaticCopy : [Person] = []
    var showingStarredUsersOnly : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sizeTabBar()
        setUpRefreshControl()
        peopleNearbyStaticCopy = FirebaseNetworkController.sharedInstance.peopleNearby
        
        if FirebaseNetworkController.sharedInstance.peopleNearby.count >= 1 {
            
            if let timeAtLastLocation = FirebaseNetworkController.sharedInstance.currentPerson?.timeAtLastLocation {
                
                let lastRefreshedString = FirebaseNetworkController.sharedInstance.convertDateIntoString(timeAtLastLocation)
                
                refreshFooterLabel.text = "Last refreshed at \(lastRefreshedString)"
                
            } else {
                print("There's not a current user")
                
                refreshFooterLabel.text = ""
            }
            
        } else {
            refreshFooterLabel.text = "No users nearby. Swipe down to refresh"
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        setStarsForStarredUsers()
    }
    
    func setStarsForStarredUsers(){
        
        if let currentUser = FirebaseNetworkController.sharedInstance.currentPerson {
            
            for starredUID in currentUser.starredUsersUIDS {
                
                let starredPerson = FirebaseNetworkController.sharedInstance.peopleNearby.filter{$0.uid == starredUID}.first
                
                if let foundStarredPerson = starredPerson {
                    
                    foundStarredPerson.isStarredUser = true
                }
            }
        }
    }
    
    func setUpRefreshControl () {
        
        refreshUsersNearbyControl.backgroundColor = AppearenceController.purpleColor
        refreshUsersNearbyControl.tintColor = UIColor.whiteColor()
        refreshUsersNearbyControl.addTarget(self, action: "refreshNearbyUsersTapped", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshUsersNearbyControl)
    }
    
    func refreshNearbyUsersTapped(){
        
        peopleNearbyStaticCopy = FirebaseNetworkController.sharedInstance.peopleNearby
        
        tableView.reloadData()
        
        refreshUsersNearbyControl.endRefreshing()
        
        let lastRefreshedString = FirebaseNetworkController.sharedInstance.convertDateIntoString(NSDate())
        refreshFooterLabel.text = "Last refreshed at \(lastRefreshedString)"
    }
    
    func sizeTabBar() {
        
        segControl.frame = CGRectMake(0, self.view.frame.size.height - 100.0, self.view.frame.size.width, 100.0)
    }
    
    //MARK: tab bar value changed method
    
    @IBAction func segControlValueChanged(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            
            showingStarredUsersOnly = false
            tableView.tableFooterView?.hidden = false
            tableView.addSubview(refreshUsersNearbyControl)
            tableView.reloadData()
            
        } else {
            showingStarredUsersOnly = true
            refreshUsersNearbyControl.removeFromSuperview()
            tableView.tableFooterView?.hidden = true
            tableView.reloadData()
        }
    }
    
    //MARK: star button tapped method
    
    @IBAction func starButtonTapped(sender: UIButton) {
        
        let cell = sender.superview!.superview! as! UITableViewCell  //can't we use tags on buttons or something?
        
        if let cellIndexPath = tableView.indexPathForCell(cell) {
            
            var person : Person!
            
            if segControl.selectedSegmentIndex == 0 {
                
                person = peopleNearbyStaticCopy[cellIndexPath.row]
                
            } else {
                person = FirebaseNetworkController.sharedInstance.starredPeople[cellIndexPath.row]
                
                let nearbyUserToUnstar = peopleNearbyStaticCopy.filter{ $0.uid == person.uid }.first
                
                if let foundNearbyUserToUnstar = nearbyUserToUnstar {
                    
                    foundNearbyUserToUnstar.isStarredUser = false
                }
            }
            
            
            if person.isStarredUser == true {
                
                person.isStarredUser = false
                FirebaseNetworkController.sharedInstance.deleteStarredUserWithUID(person.uid)
                tableView.reloadData()
                
            } else {
                //add that star, yo!
                person.isStarredUser = true
                FirebaseNetworkController.sharedInstance.starPersonWithUID(person)
                tableView.reloadRowsAtIndexPaths([cellIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
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
                
                let person : Person!
                
                if segControl.selectedSegmentIndex == 0 {
                    
                    person = peopleNearbyStaticCopy[indexPath.row]
                    
                } else {
                    person = FirebaseNetworkController.sharedInstance.starredPeople[indexPath.row]
                }
                
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
        
        if showingStarredUsersOnly == false {
            return peopleNearbyStaticCopy.count
            
        } else {
            return FirebaseNetworkController.sharedInstance.starredPeople.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(personCellID, forIndexPath: indexPath) as! PersonTableViewCell
        
        var person : Person!
        
        if showingStarredUsersOnly == false {
            
            //use the static copy if we're showing everyone nearby
            person = peopleNearbyStaticCopy[indexPath.row]
            
        } else {
            //else show the starred people
            person = FirebaseNetworkController.sharedInstance.starredPeople[indexPath.row]
        }
        
        if let image = person.image {
            cell.userImageView.image = image
            
        } else {
            cell.userImageView.image = UIImage(named: "blankProfileGray")
        }
        
        if person.isStarredUser == true {
            cell.starButton.setBackgroundImage(UIImage(named:"starred"), forState: .Normal)
            
        } else {
            cell.starButton.setBackgroundImage(UIImage(named: "unstarred"), forState: .Normal)
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

