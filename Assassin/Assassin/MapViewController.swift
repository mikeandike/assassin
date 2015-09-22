//
//  MapViewController.swift
//  Assassin
//
//  Created by Michael Sacks on 9/14/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    let personNearbyCellID = "personNearbyCellID"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension MapViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let peopleNearby = FirebaseNetworkController.sharedInstance.peopleNearby {
            
            return peopleNearby.count
        }
        
        return Int(0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(personNearbyCellID, forIndexPath: indexPath) as! PersonNearbyTableViewCell
        
        if let peopleNearby = FirebaseNetworkController.sharedInstance.peopleNearby {
            
            let person = peopleNearby[indexPath.row]
            
            cell.userImageView.image = person.image
            cell.nameLabel.text = person.firstName + person.lastName
            cell.companyLabel.text = person.company
            cell.jobTitleLabel.text = person.jobTitle
            
        }
        
        return cell
    }
    
}

