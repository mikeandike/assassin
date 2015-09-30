//
//  StarredUserDataSource.swift
//  Assassin
//
//  Created by Mattthew Bailey on 9/29/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit

class StarredUserDataSource : NSObject, UITableViewDataSource, UITableViewD {
    
    let starredPersonCellID = "starredPersonCellID"
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FirebaseNetworkController.sharedInstance.starredPeople.count
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(starredPersonCellID, forIndexPath: indexPath) as! PersonTableViewCell
        
        let person = FirebaseNetworkController.sharedInstance.starredPeople[indexPath.row]
        
        if let image = person.image {
            cell.userImageView.image = image
            
        } else {
            cell.userImageView.image = UIImage(named: "blankProfileGray")
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