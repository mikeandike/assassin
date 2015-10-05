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
    case ProfileInformationTypeBioCell
    case ProfileInformationTypeContactCell
    
    static var count: Int {return ProfileInformationTypes.ProfileInformationTypeContactCell.hashValue + 1}
    
}

enum ContactInformationTypes : Int {
    
    case ContactInformationTypePhone
    case ContactInformationTypeEmail
    
    static var count: Int {return ContactInformationTypes.ContactInformationTypeEmail.hashValue + 1}
    
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
        
        self.tabBarController?.tabBar.hidden = true

        // Do any additional setup after loading the view.
        if isCurrentUsersProfile == false {
            
            editButton.tintColor = UIColor.clearColor()
            editButton.enabled = false
            
        } else {
            
            editButton.tintColor = AppearenceController.tealColor
            editButton.enabled = true
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.profileTableView.reloadData()
    }
    
    
    //MARK: prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "presentDetailViewFromCell" {
            
            //deselect row at index Path
            
            let cell = sender as! UITableViewCell
            
            if let indexPath = profileTableView.indexPathForCell(cell) {
            
            profileTableView.deselectRowAtIndexPath(indexPath, animated: true)
                
                }
            
        } else if segue.identifier == "presentEditProfileVC" {
            
            //pass textview heights to next VC
            
            let editProfileVC = segue.destinationViewController as! EditProfileViewController
            editProfileVC.purposeTextViewHeight = purposeTextViewHeight
            editProfileVC.bioTextViewHeight = bioTextViewHeight
            
            
        }
    }
  

   
    
    
   //MARK: tableview delegate methods
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch ProfileInformationTypes(rawValue: indexPath.section)! {
            
        case .ProfileInformationTypeMainCell:
            
            return 281
            
        case .ProfileInformationTypePurposeCell:
            
            if let purposeString = person.purpose {
            
            purposeTextViewHeight = AppearenceController.getHeightOfTextWithFont(purposeString, font: AppearenceController.mediumSmallText, view: self.view)
                
            }
            
            return purposeTextViewHeight
         
        case .ProfileInformationTypeBioCell:
            
            if let bioString = person.bio {
                
                bioTextViewHeight = AppearenceController.getHeightOfTextWithFont(bioString, font: AppearenceController.mediumSmallText, view: self.view)
                
            }
            
            return bioTextViewHeight
            
        case .ProfileInformationTypeContactCell:
            
            return 48
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        switch ProfileInformationTypes(rawValue: section)! {
            
        case .ProfileInformationTypeMainCell:
            
            return CGFloat(1)
            
        case .ProfileInformationTypePurposeCell:
            
           return CGFloat(25)
            
        case .ProfileInformationTypeBioCell:
            
            return CGFloat(25)
            
        case .ProfileInformationTypeContactCell:
            
            return CGFloat(25)
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return ProfileInformationTypes.count
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch ProfileInformationTypes(rawValue: section)! {
            
        case .ProfileInformationTypeMainCell:
            
            return 1
            
        case .ProfileInformationTypePurposeCell:
            
            return 1
            
        case .ProfileInformationTypeBioCell:
            
            return 1
            
        case .ProfileInformationTypeContactCell:
            
            return 2
            
        }
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch ProfileInformationTypes(rawValue: section)! {
            
        case .ProfileInformationTypeMainCell:
            
            return ""
            
        case .ProfileInformationTypePurposeCell:
            
            return "Purpose"
            
        case .ProfileInformationTypeBioCell:
            
            return "Bio"
            
        case .ProfileInformationTypeContactCell:
            
            return "Contact"
            
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch ProfileInformationTypes(rawValue: indexPath.section)! {
            
        case .ProfileInformationTypeMainCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(mainCellID, forIndexPath: indexPath) as! MainTableViewCell
            
            if let image = person.image {
                
                cell.bioImageView.image = image
                
            } else {
                
                cell.bioImageView.image = UIImage(named: "blankProfileGray")
                
            }
            
            cell.nameLabel.text = person.firstName + " " + person.lastName
            cell.nameLabel.font = AppearenceController.bigText
            
            if let company = person.company {
                
                if company == "" {
                  
                    cell.companyLabel.text = "Company"
                    cell.companyLabel.textColor = UIColor.lightGrayColor()

                    
                } else {
                    
                    cell.companyLabel.text = company
                    cell.companyLabel.textColor = UIColor.blackColor()
                    cell.companyLabel.font = AppearenceController.mediumBigText
                    
                }
                
                
            } else {
                
                cell.companyLabel.text = "Company"
                cell.companyLabel.textColor = UIColor.lightGrayColor()
                //TODO: decide on empty state font
            }
            
            if let jobTitle = person.jobTitle {
                
                cell.jobTitleLabel.text = jobTitle
                cell.jobTitleLabel.textColor = UIColor.blackColor()
                cell.jobTitleLabel.font = AppearenceController.mediumSmallText
                
            } else {
                
                cell.jobTitleLabel.text = "Job Title"
                cell.jobTitleLabel.textColor = UIColor.lightGrayColor()
                //TODO: decide on empty state font
                
            }
            
            if let timeAtLastLocation = person.timeAtLastLocation {
                
                let timeString = FirebaseNetworkController.sharedInstance.convertDateIntoString(timeAtLastLocation)
                
                cell.lastActiveLabel.text = "Last active at " + timeString
                cell.lastActiveLabel.font = AppearenceController.tinyText
                
            }
            
            return cell
            
        case .ProfileInformationTypePurposeCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(purposeCellID, forIndexPath: indexPath) as! PurposeTableViewCell
            
            
                if let purpose = person.purpose {
                    
                    cell.purposeLabel.text = purpose
                    cell.purposeLabel.textColor = UIColor.blackColor()
                    cell.purposeLabel.font = AppearenceController.mediumSmallText
                    
                } else {
                    
                    cell.purposeLabel.text = "Here to"
                    cell.purposeLabel.textColor = UIColor.lightGrayColor()
                    //TODO: decide on empty state font
                }
                
            
       
            return cell
       
        case .ProfileInformationTypeBioCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(purposeCellID, forIndexPath: indexPath) as! PurposeTableViewCell
            
            
                if let bio = person.bio {
                    
                    cell.purposeLabel.text = bio
                    cell.purposeLabel.textColor = UIColor.blackColor()
                    cell.purposeLabel.font = AppearenceController.mediumSmallText
                    
                } else {
                    
                    cell.purposeLabel.text = "Bio"
                    cell.purposeLabel.textColor = UIColor.lightGrayColor()
                    //TODO: decide on empty state font
                }
                
            
            
            return cell

         
        case .ProfileInformationTypeContactCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(contactCellID, forIndexPath: indexPath) as! ContactTableViewCell

            switch ContactInformationTypes(rawValue: indexPath.row)! {
                
            case .ContactInformationTypePhone:
                
                cell.contactImageView.image = UIImage(named: "phoneIcon")

                if let phone = person.phoneNumber {
                    
                    cell.contactLabel.text = phone
                    cell.contactLabel.textColor = UIColor.blackColor()
                    cell.contactLabel.font = AppearenceController.mediumSmallText
                    
                } else {
                    
                    cell.contactLabel.text = "Phone"
                    cell.contactLabel.textColor = UIColor.lightGrayColor()
                    //TODO: decide on empty state font
                }
                
                return cell
                
            case .ContactInformationTypeEmail:
            
            cell.contactLabel.text = person.email
            cell.contactLabel.font = AppearenceController.mediumSmallText
            cell.contactImageView.image = UIImage(named: "emailIcon")
            
            
            return cell
        }
    }
    
  }
}
