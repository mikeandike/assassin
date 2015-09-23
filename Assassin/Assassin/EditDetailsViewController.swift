//
//  EditDetailsViewController.swift
//  Assassin
//
//  Created by Michael Sacks on 9/23/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit

enum EditJobTypes : Int {
    
    case EditJobTypeCompanyCell
    case EditJobTypeJobTitleCell
    
    static var count: Int {return EditJobTypes.EditJobTypeJobTitleCell.hashValue + 1}
    
}

enum EditPurposeTypes: Int {
    
    case EditPurposeTypePurpose
    case EditPurposeTypeBio
    
    static var count: Int {return EditPurposeTypes.EditPurposeTypeBio.hashValue + 1}
    
}

enum EditContactTypes: Int {
    
    case EditContactTypeEmail
    case EditContactTypePhone
    
    static var count: Int {return EditContactTypes.EditContactTypePhone.hashValue + 1}
    
}

enum EditProfileInformationSectionTypes : Int {
    
     case EditProfileInformationSectionTypeNamePhoto
     case EditProfileInformationSectionTypeJob
     case EditProfileInformationSectionTypePurpose
     case EditProfileInformationSectionTypeContact
    
    static var count: Int {return EditProfileInformationSectionTypes.EditProfileInformationSectionTypeContact.hashValue + 1}
}

class EditDetailsViewController: UIViewController {
    
    var person : Person
    
    let namePhotoCellID = "namePhotoCellID"
    let textFieldCellID = "textFieldCellID"
    let textViewCellID = "textViewCellID"

    
    init(person : Person) {
        
        self.person = person
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

extension EditDetailsViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch EditProfileInformationSectionTypes(rawValue: indexPath.section)! {
            
        case .EditProfileInformationSectionTypeNamePhoto:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(namePhotoCellID, forIndexPath: indexPath) as! NamePhotoTableViewCell
            
            cell.firstNameTextField.text = person.firstName
            cell.lastNameTextField.text = person.lastName
            
            //need to put something here to not let person completely delete name
            
            return cell
            
        case .EditProfileInformationSectionTypeJob:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(textFieldCellID, forIndexPath: indexPath) as! TextFieldTableViewCell
            
            switch EditJobTypes(rawValue: indexPath.row)! {
                
            case .EditJobTypeCompanyCell:
               
            
                if let company = person.company {
                    
                    cell.infoTextField.text = company
                    
                } else {
                    
                    cell.infoTextField.placeholder = "Company"
                    
                }
                
                return cell
                
                
            case .EditJobTypeJobTitleCell:
                
                if let jobTitle = person.jobTitle {
                    
                    cell.infoTextField.text = jobTitle
                    
                } else {
                    
                    cell.infoTextField.placeholder = "Job Title"
                    
                }
                
                return cell
                
            }
            
            
        case .EditProfileInformationTypeNameJobTitleCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(textFieldCellID, forIndexPath: indexPath) as! TextFieldTableViewCell
            
            if let jobTitle = person.jobTitle {
                
                cell.infoTextField.text = jobTitle
                
            } else {
                
                cell.infoTextField.placeholder = "Job Title"
                
            }
            
            return cell
            
        case .Edit:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(contactCellID, forIndexPath: indexPath) as! ContactTableViewCell
            
            cell.contactLabel.text = person.email
            
            return cell
        }
    }
    
}
