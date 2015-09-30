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
    
    var showingStarredUsersOnly : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sizeTabBar()
        
        setUpRefreshControl()
        
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
    }
    
    func setUpRefreshControl () {
        
        refreshUsersNearbyControl.backgroundColor = AppearenceController.purpleColor
        refreshUsersNearbyControl.tintColor = UIColor.whiteColor()
        refreshUsersNearbyControl.addTarget(self, action: "refreshNearbyUsersTapped", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshUsersNearbyControl)
        
    }
    
    func refreshNearbyUsersTapped(){
        
        tableView.reloadData()
        
        refreshUsersNearbyControl.endRefreshing()
        
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
    

    
   
    
    
    @IBAction func starButtonTapped(sender: UIButton) {
        
       let cell = sender.superview!.superview! as! PersonTableViewCell
        
        if let indexPath = tableView.indexPathForCell(cell) {
        
            let starredPerson = FirebaseNetworkController.sharedInstance.peopleNearby[indexPath.row]
            FirebaseNetworkController.sharedInstance.setStarUser(starredPerson.uid)
            self.tableView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: tableview delegate methods
    
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
        
        if showingStarredUsersOnly == false {
        
            return FirebaseNetworkController.sharedInstance.peopleNearby.count
            
        } else {
        
            return FirebaseNetworkController.sharedInstance.starredPeople.count
            
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(personCellID, forIndexPath: indexPath) as! PersonTableViewCell
        
        
        var person : Person!
        
        if showingStarredUsersOnly == false {
            
            person = FirebaseNetworkController.sharedInstance.peopleNearby[indexPath.row]
            
        } else {
            
            person = FirebaseNetworkController.sharedInstance.starredPeople[indexPath.row]
            
        }
        
        
        if let image = person.image {
            
            cell.userImageView.image = image

        } else {
            
            cell.userImageView.image = UIImage(named: "blankProfileGray")
        }
        
       if  let starrStrings = (FirebaseNetworkController.sharedInstance.starredStrings as? [String]) {
            for var i = 0; i < FirebaseNetworkController.sharedInstance.starredStrings.count; ++i {
                if(person.uid == starrStrings[i] ) {
                    cell.starButton.imageView?.image = UIImage(named: "starred")
                } else {
                    cell.starButton.imageView?.image = UIImage(named: "unstarred")
                }
            }
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

//extension PersonListViewController : UITabBarControllerDelegate {
//    
//    @objc func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
//        
//////        var navController = viewController as! UINavigationController;
//////            navController.
//////        }
//////        
//////        if viewController.isKindOfClass(UINavigationController) {
////            self.tableView.reloadData()
//////        }
//////    }
//    
//}