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


class PersonNearbyDetailViewController: UIViewController, UITableViewDelegate {
    
    var person = Person(firstName: "John", lastName: "Doe", email: "doe@net.net", password: "", uid: "")

    let mainCellID = "mainCellID"
    let purposeCellID = "purposeCellID"
    let contactCellID = "contactCellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  

    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("presentEditDetailVC", sender: self)
        
    }
    
    
   //MARK: tableview delegate methods
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch ProfileInformationTypes(rawValue: indexPath.row)! {
            
        case .ProfileInformationTypeMainCell:
            
            return 281
            
        case .ProfileInformationTypePurposeCell:
            
            return 119
            
        case .ProfileInformationTypePhoneCell:
            
            return 48
            
        case .ProfileInformationTypeEmailCell:
            
            return 48
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension PersonNearbyDetailViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ProfileInformationTypes.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch ProfileInformationTypes(rawValue: indexPath.row)! {
            
        case .ProfileInformationTypeMainCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(mainCellID, forIndexPath: indexPath) as! MainTableViewCell
            
            cell.bioImageView.image = person.image
            cell.nameLabel.text = person.firstName + " " + person.lastName
            cell.companyLabel.text = person.company
            cell.jobTitleLabel.text = person.jobTitle
            cell.lastActiveLabel.text = person.timeAtLastLocation?.description
            
            return cell
            
        case .ProfileInformationTypePurposeCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(purposeCellID, forIndexPath: indexPath) as! PurposeTableViewCell
            
            cell.purposeLabel.text = person.purpose
            cell.bioLabel.text = person.bio
            
            return cell
            
        case .ProfileInformationTypePhoneCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(contactCellID, forIndexPath: indexPath) as! ContactTableViewCell
            
            cell.contactImageView.image = UIImage(named:"phoneIcon")
            cell.contactLabel.text = person.phoneNumber
            
            return cell
            
        case .ProfileInformationTypeEmailCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(contactCellID, forIndexPath: indexPath) as! ContactTableViewCell
            
            cell.contactImageView.image = UIImage(named:"emailIcon")
            cell.contactLabel.text = person.email
            
            return cell
        }
    }
    
    
}
