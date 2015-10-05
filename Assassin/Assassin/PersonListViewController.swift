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
    
    //This copy of the array currently never changes
    //BUT When you reload the tableview, this copy should be set to the peopleNearby from firebase network controller
    
    //Need to figure out the place to initiate it
    var peopleNearbyStaticCopy : [Person] = []
    
    var showingStarredUsersOnly : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tests
        
        print("FNC STARRED PEOPLE : \(FirebaseNetworkController.sharedInstance.starredPeople)")
        
        if let currentUser = FirebaseNetworkController.sharedInstance.currentPerson {
        
            print("FNC CURRENT USER STARRED USER UIDS : \(currentUser.starredUsersUIDS)")
            
        }
        
        sizeTabBar()
        
        setUpRefreshControl()
        
            setStarsForStarredUsers()
        
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
    }
    
    func setStarsForStarredUsers(){
        
        if let currentUser = FirebaseNetworkController.sharedInstance.currentPerson {
            
            for starredUID in currentUser.starredUsersUIDS {
                
                let starredPerson = FirebaseNetworkController.sharedInstance.peopleNearby.filter{$0.uid == starredUID}.first
                
                if let foundStarredPerson = starredPerson {
                    
                    var personToStar = foundStarredPerson
                    
                    personToStar.isStarredUser = true
                    
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
        
        let cell = sender.superview!.superview! as! UITableViewCell
        
        if let cellIndexPath = tableView.indexPathForCell(cell) {
            
            var person : Person!
            
            if segControl.selectedSegmentIndex == 0 {
                
                person = peopleNearbyStaticCopy[cellIndexPath.row]
                
                print("\(person.firstName) was tapped on")
                
            } else {
                
                person = FirebaseNetworkController.sharedInstance.starredPeople[cellIndexPath.row]
                
                print("\(person.firstName) was tapped on")
                
            }
            
            if person.isStarredUser == true {
                
                print("\(person.firstName) was a starred User at time of tap")
                
                person.isStarredUser = false
                
                FirebaseNetworkController.sharedInstance.deleteStarredUserWithUID(person.uid)
                
                
            } else {
                
                print("\(person.firstName) was NOT a starred User at time of tap")
                
                //add that star yo
                
                person.isStarredUser = true
                
                FirebaseNetworkController.sharedInstance.starPersonWithUID(person)
                
                print("\(person.firstName) is now a starred User: \(person.isStarredUser)")
            }
            
            tableView.reloadRowsAtIndexPaths([cellIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//            tableView.reloadData()
            print("tableview reloaded")
            
        
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
            
            //use the static copy if were showing everyone nearby
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
            
            cell.starButton.imageView?.image = UIImage(named: "starred")
            print("\(person.firstName) is starred")
            
            if let currentUser = FirebaseNetworkController.sharedInstance.currentPerson {
                
                print("current person starred UIDS : \(currentUser.starredUsersUIDS)")
                print("starredPeople : \(FirebaseNetworkController.sharedInstance.starredPeople)")
                
            }
            
        } else {
            
            cell.starButton.imageView?.image = UIImage(named: "unstarred")
            print("\(person.firstName) is unstarred")
            
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