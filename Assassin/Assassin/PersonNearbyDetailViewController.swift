//
//  PersonNearbyDetailViewController.swift
//  Assassin
//
//  Created by Michelle Tessier on 9/14/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit


enum ProfileInformationTypes : Int {
    
    case ProfileInformationTypeMainCell
    case ProfileInformationTypePurposeCell
    case ProfileInformationTypePhoneCell
    case ProfileInformationTypeEmailCell
    
    static var count: Int {return ProfileInformationTypes.ProfileInformationTypeEmailCell.hashValue + 1}
    
}


class PersonNearbyDetailViewController: UIViewController {

    let mainCellID = "mainCellID"
    let purposeCellID = "purposeCellID"
    let contactCellID = "contactCellID"
    
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


extension PersonNearbyDetailViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ProfileInformationTypes.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell
        
        switch ProfileInformationTypes(rawValue: indexPath.row)! {
            
        case ProfileInformationTypes.ProfileInformationTypeMainCell:
            
            cell = tableView.dequeueReusableCellWithIdentifier(mainCellID, forIndexPath: indexPath) as! MainTableViewCell
            
        case ProfileInformationTypes.ProfileInformationTypePurposeCell:
            
            cell = tableView.dequeueReusableCellWithIdentifier(purposeCellID, forIndexPath: indexPath) as! PurposeTableViewCell
            
        case ProfileInformationTypes.ProfileInformationTypePhoneCell:
            
            fallthrough
            
        case ProfileInformationTypes.ProfileInformationTypeEmailCell:
            
            cell = tableView.dequeueReusableCellWithIdentifier(contactCellID, forIndexPath: indexPath)
            
        }
        
        return cell
    }
    
    
    
}

