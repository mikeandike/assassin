//
//  PersonDetailViewController.swift
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


class PersonDetailViewController: UIViewController, UITableViewDelegate {
    
    
    @IBOutlet weak var profileTableView: UITableView!
    
    var person : Person!
    
    var purposeTextViewHeight : CGFloat = 48.0
    var bioTextViewHeight : CGFloat = 48.0

    var isCurrentUsersProfile : Bool = false
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    let mainCellID = "mainCellID"
    let purposeCellID = "purposeCellID"
    let contactCellID = "contactCellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if isCurrentUsersProfile == false {
            
            editButton.tintColor = UIColor.clearColor()
            editButton.enabled = false
            
        } else {
            
            editButton.tintColor = UIColor.blackColor()
            editButton.enabled = true
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.profileTableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "presentDetailViewFromCell" {
            
            let cell = sender as! UITableViewCell
            
            if let indexPath = profileTableView.indexPathForCell(cell) {
            
            profileTableView .deselectRowAtIndexPath(indexPath, animated: true)
                
                }
            
        } else if segue.identifier == "presentEditProfileVC" {
            
            let editProfileVC = segue.destinationViewController as! EditProfileViewController
            editProfileVC.purposeTextViewHeight = purposeTextViewHeight
            editProfileVC.bioTextViewHeight = bioTextViewHeight
            
            
        }
    }
  

   
    
    
   //MARK: tableview delegate methods
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch ProfileInformationTypes(rawValue: indexPath.row)! {
            
        case .ProfileInformationTypeMainCell:
            
            return 281
            
        case .ProfileInformationTypePurposeCell:
            
            switch EditPurposeTypes(rawValue: indexPath.row)! {
                
            case .EditPurposeTypePurpose:
                
                return purposeTextViewHeight
                
            case .EditPurposeTypeBio:
                
                return bioTextViewHeight
                
            }
            
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


extension PersonDetailViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ProfileInformationTypes.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch ProfileInformationTypes(rawValue: indexPath.row)! {
            
        case .ProfileInformationTypeMainCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(mainCellID, forIndexPath: indexPath) as! MainTableViewCell
            
            if let image = person.image {
                
                cell.bioImageView.image = image
                
            } else {
                
                //cell.bioImageView.image = fakeImage
                
            }
            
            cell.nameLabel.text = person.firstName + " " + person.lastName
            
            if let company = person.company {
                
                cell.companyLabel.text = company
                cell.companyLabel.textColor = UIColor.blackColor()
                
            } else {
                
                cell.companyLabel.text = "Company"
                cell.companyLabel.textColor = UIColor.lightGrayColor()
                
            }
            
            if let jobTitle = person.jobTitle {
                
                cell.jobTitleLabel.text = jobTitle
                cell.jobTitleLabel.textColor = UIColor.blackColor()
                
            } else {
                
                cell.jobTitleLabel.text = "Job Title"
                cell.jobTitleLabel.textColor = UIColor.lightGrayColor()
                
            }
            
            if let timeAtLastLocation = person.timeAtLastLocation {
                
                let timeString = FirebaseNetworkController.sharedInstance.convertDateIntoString(timeAtLastLocation)
                
                cell.lastActiveLabel.text = "Last active at " + timeString
                
            }
            
            return cell
            
        case .ProfileInformationTypePurposeCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(purposeCellID, forIndexPath: indexPath) as! PurposeTableViewCell
            
            if let purpose = person.purpose {
                
                cell.purposeLabel.text = purpose
                cell.purposeLabel.textColor = UIColor.blackColor()
                
            } else {
                
                cell.purposeLabel.text = "Here to"
                cell.purposeLabel.textColor = UIColor.lightGrayColor()
            }
            
            if let bio = person.bio {
                
                cell.bioLabel.text = bio
                cell.bioLabel.textColor = UIColor.blackColor()
                
            } else {
                
                cell.bioLabel.text = "Bio"
                cell.bioLabel.textColor = UIColor.lightGrayColor()
            }
            
            return cell
            
        case .ProfileInformationTypePhoneCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(contactCellID, forIndexPath: indexPath) as! ContactTableViewCell
            
            if let phone = person.phoneNumber {
                
               cell.contactLabel.text = phone
               cell.contactLabel.textColor = UIColor.blackColor()
                
            } else {
                
                cell.contactLabel.text = "Phone"
                cell.contactLabel.textColor = UIColor.lightGrayColor()
            }
            
            return cell
            
        case .ProfileInformationTypeEmailCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(contactCellID, forIndexPath: indexPath) as! ContactTableViewCell
            
            cell.contactLabel.text = person.email
            
            return cell
        }
    }
    
    
}
