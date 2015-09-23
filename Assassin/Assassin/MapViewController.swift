//
//  MapViewController.swift
//  Assassin
//
//  Created by Michael Sacks on 9/14/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let personNearbyCellID = "personNearbyCellID"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destinationViewCon = segue.destinationViewController as! PersonNearbyDetailViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            let person = FirebaseNetworkController.sharedInstance.peopleNearby[indexPath.row]
            
            destinationViewCon.person = person
        }
    }
}



extension MapViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FirebaseNetworkController.sharedInstance.peopleNearby.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(personNearbyCellID, forIndexPath: indexPath) as! PersonNearbyTableViewCell
        
        let person = FirebaseNetworkController.sharedInstance.peopleNearby[indexPath.row]
        
        cell.userImageView.image = person.image
        cell.nameLabel.text = person.firstName + " " + person.lastName
        cell.companyLabel.text = person.company
        cell.jobTitleLabel.text = person.jobTitle
        
        return cell
    }
    
}

