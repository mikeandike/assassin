//
//  EditProfileViewController.swift
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

class EditProfileViewController: UIViewController, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!

    var person = FirebaseNetworkController.sharedInstance.currentPerson! //TODO: need to find a better way of doing this
    var purposeTextViewHeight : CGFloat = 48.0
    var bioTextViewHeight : CGFloat = 48.0
    
    @IBOutlet weak var viewLengthLabel: UILabel!
    
    let namePhotoCellID = "namePhotoCellID"
    let textFieldCellID = "textFieldCellID"
    let textViewCellID = "textViewCellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let purposeString = person.purpose {
        
        purposeTextViewHeight = getHeightOfTextWithFont(purposeString, font: UIFont.systemFontOfSize(17))
            
        }
        
        if let bioString = person.bio {
            
            bioTextViewHeight = getHeightOfTextWithFont(bioString, font: UIFont.systemFontOfSize(17))
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        
        self.navigationController!.popViewControllerAnimated(true)
        
    }
    
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        
        self.view.endEditing(true)
        
        saveProfile()
        
        self.navigationController!.popViewControllerAnimated(true)
        
    }
    
    
    @IBAction func imageButtonTapped(sender: UIButton) {
        
       loadImagePickerView()
        
    }
    
    //MARK: method to add characters remaining to textViews

    
    func textViewDidChange(textView: UITextView) {
        
        let cell = textView.superview!.superview! as! TextViewTableViewCell
        
        let textViewCharacterCount = textView.text.characters.count
        
        let characterCountString = "\(140-textViewCharacterCount)"
        
        cell.characterCountLabel.text = characterCountString
        
        if let indexPath = tableView.indexPathForCell(cell) {
        
            switch EditPurposeTypes(rawValue: indexPath.row)! {
                
            case .EditPurposeTypePurpose:
                
                let textHeight = getHeightOfTextWithFont(textView.text, font: cell.purposeTextView.font!)
                
                if textHeight > purposeTextViewHeight {
                    
                purposeTextViewHeight = textHeight
                
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                }
                
            case .EditPurposeTypeBio:
                
                let textHeight = getHeightOfTextWithFont(textView.text, font: cell.purposeTextView.font!)
                
                if textHeight > bioTextViewHeight {
                
                 bioTextViewHeight = textHeight
                
                 tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                }
                
            }
        }
        
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text.characters.count == 0 {
            
            if textView.text.characters.count != 0 {
                
                return true
                
            }
            
        } else if textView.text.characters.count > 140 {
                
                return false
                
            }
                
            return true
            
    }
        

    
    func getHeightOfTextWithFont(textString : String, font : UIFont) -> CGFloat {
        
        return (textString as String).boundingRectWithSize(CGSize(width: self.view.frame.size.width - 10, height: CGFloat.max),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil).size.height
        
    }
    
    //MARK: UITableViewDelegate methods
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
            
            switch EditProfileInformationSectionTypes(rawValue: indexPath.section)! {
                
            case .EditProfileInformationSectionTypeNamePhoto:
                
                return 130.0
                
            case .EditProfileInformationSectionTypeJob:
               
                return 48.0
                
            case .EditProfileInformationSectionTypePurpose:
                
                switch EditPurposeTypes(rawValue: indexPath.row)! {
                    
                case .EditPurposeTypePurpose:
                    
                  
                    
                    return purposeTextViewHeight
                    
                case .EditPurposeTypeBio:
                    
                    
                    
                    return bioTextViewHeight
                    
                }
                
            case .EditProfileInformationSectionTypeContact:
                
                return 48.0
                
            }
        
    }
    
    
    func loadImagePickerView() {
        
        let imagePickerController = UIImagePickerController.init()
        imagePickerController.delegate = self
        
        let photoActionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        
        
        let cameraRollAction = UIAlertAction.init(title: "From Library", style: UIAlertActionStyle.Default) { (action) -> Void in
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePickerController, animated: true, completion: nil)
            
        }
        
        photoActionSheet.addAction(cameraRollAction)
        
        let takePictureAction = UIAlertAction.init(title: "Take Picture", style: UIAlertActionStyle.Default) { (action) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == true {
                
                imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.Front
                imagePickerController.allowsEditing = true
                
                self.presentViewController(imagePickerController, animated: true, completion: nil)
                
            } else {
                
                let noCameraAlert = UIAlertController.init(title: "Camera not available", message: "Please choose photo from library", preferredStyle: UIAlertControllerStyle.Alert)
                
                let dismissAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                    [self .dismissViewControllerAnimated(true, completion: nil)];
                })
                
                noCameraAlert.addAction(dismissAction)
                
                self.presentViewController(noCameraAlert, animated: true, completion: nil)
                
            }
        }
        
        photoActionSheet.addAction(takePictureAction)
        
        presentViewController(photoActionSheet, animated: true, completion: nil)
        
    }
    

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        person.image = image
        self.tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    //MARK: - textFieldDelegateMethods - dismissing keyboard
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - saving edited fields

    func textFieldDidEndEditing(textField: UITextField) {
        
        updateTemporaryPersonWithText(textField)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        updatePersonWithTextView(textView)
    }
    
   
    
    func updatePersonWithTextView(textView : UITextView) {
        
        let cell = textView.superview!.superview! as! TextViewTableViewCell
        
        if let indexPath = self.tableView.indexPathForCell(cell) {
            
            switch EditProfileInformationSectionTypes(rawValue: indexPath.section)! {
                
            case .EditProfileInformationSectionTypeNamePhoto:
                break
                
            case .EditProfileInformationSectionTypeJob:
                break
                
            case .EditProfileInformationSectionTypePurpose:
              
                switch EditPurposeTypes(rawValue: indexPath.row)! {
                    
                case .EditPurposeTypePurpose:
                    
                    person.purpose = cell.purposeTextView.text
                    
                case .EditPurposeTypeBio:
                    
                    person.bio = cell.purposeTextView.text
                    
                }
                
            case .EditProfileInformationSectionTypeContact:
                break
             
            }
        }
    }
    
    func updateTemporaryPersonWithText(textField : UITextField) {
        
        let cell = textField.superview!.superview! as! UITableViewCell
        
        if let indexPath = self.tableView.indexPathForCell(cell) {
            
            switch EditProfileInformationSectionTypes(rawValue: indexPath.section)! {
                
            case .EditProfileInformationSectionTypeNamePhoto:
                
                let namePhotoCell = cell as! NamePhotoTableViewCell
                
                if let firstNameText = namePhotoCell.firstNameTextField.text {
                
                    //prevents from saving first or last names with 0 or 1 letter:
                    //should we also have a warning pop up and/or prevent the from leaving the screen?
                    
                    if firstNameText.characters.count > 1 {
                        person.firstName = firstNameText
                    }
                }
                
                if let lastNameText = namePhotoCell.lastNameTextField.text {
                    
                    if lastNameText.characters.count > 1 {
                        person.lastName = lastNameText
                    }
                }
                
             
            case .EditProfileInformationSectionTypeJob:
                
                let textFieldCell = cell as! TextFieldTableViewCell
                
                switch EditJobTypes(rawValue: indexPath.row)! {
                    
                case .EditJobTypeCompanyCell:
                    
                    person.company = textFieldCell.infoTextField.text
                    
                case .EditJobTypeJobTitleCell:
                    
                    person.jobTitle = textFieldCell.infoTextField.text
                }
                
            case .EditProfileInformationSectionTypePurpose:
                break;
               
                
            case .EditProfileInformationSectionTypeContact:
                
                let textFieldCell = cell as! TextFieldTableViewCell
                
                switch EditContactTypes(rawValue: indexPath.row)! {
                    
                case .EditContactTypePhone:
                    
                    person.phoneNumber = textFieldCell.infoTextField.text
                    
                case .EditContactTypeEmail:
                    
                    if let textFieldText = textFieldCell.infoTextField.text {
                        
                        //only saves email if it passes email test (the one we've been using)
                        //again, like with names, should we have a warning and/or prevent screen from popping?
                        
                        if textFieldText.characters.count > 5 && textFieldText.containsString("@") && textFieldText.containsString(".") {
                            person.email = textFieldText

                        }
                    }
                }
                
            }
            
        }
        
    }
    
    
    func saveProfile() {
        
        FirebaseNetworkController.sharedInstance.savePersonIntoDictionary(person)
        
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

//MARK: - Extension: TableView DataSource

extension EditProfileViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return EditProfileInformationSectionTypes.count
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch EditProfileInformationSectionTypes(rawValue: section)! {
            
        case .EditProfileInformationSectionTypeNamePhoto:
            
            return ""
            
        case .EditProfileInformationSectionTypeJob:
            
            return "Job"
            
        case .EditProfileInformationSectionTypePurpose:
            
            return "Purpose"
            
        case .EditProfileInformationSectionTypeContact:
            
            return "Contact"
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch EditProfileInformationSectionTypes(rawValue: section)! {
            
        case .EditProfileInformationSectionTypeNamePhoto:
            
            return 1
            
        case .EditProfileInformationSectionTypeJob:
            
            return EditJobTypes.count
            
        case .EditProfileInformationSectionTypePurpose:
            
            return EditPurposeTypes.count
            
        case .EditProfileInformationSectionTypeContact:
            
            return EditContactTypes.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch EditProfileInformationSectionTypes(rawValue: indexPath.section)! {
            
        case .EditProfileInformationSectionTypeNamePhoto:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(namePhotoCellID, forIndexPath: indexPath) as! NamePhotoTableViewCell
            
            cell.firstNameTextField.text = person.firstName
            cell.lastNameTextField.text = person.lastName
            
            if let personImage = person.image {
            
                cell.imageButton.setImage(personImage, forState: UIControlState.Normal)
            
            } else {
                
                cell.imageButton.setTitle("Choose Image", forState: UIControlState.Normal)
                cell.imageButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
                
            }
            
            return cell
            
        case .EditProfileInformationSectionTypeJob:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(textFieldCellID, forIndexPath: indexPath) as! TextFieldTableViewCell
            
            
            print("CUSTOM DELEGATE\(self)")
            
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
            
            
        case .EditProfileInformationSectionTypePurpose:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(textViewCellID, forIndexPath: indexPath) as! TextViewTableViewCell
            
            
            
            switch EditPurposeTypes(rawValue: indexPath.row)! {
                
            case .EditPurposeTypePurpose:
                
                if let purpose = person.purpose {
                    
                    cell.purposeTextView.text = purpose
                    cell.purposeTextView.textColor = UIColor.blackColor()
                    
                } else {
                    
                    cell.purposeTextView.text = "Here to..."
                    cell.purposeTextView.textColor = UIColor.lightGrayColor()
                }
                
                return cell
                
            case .EditPurposeTypeBio:
                
                if let bio = person.bio {
                    
                    cell.purposeTextView.text = bio
                    cell.purposeTextView.textColor = UIColor.blackColor()
                    
                } else {
                    
                    cell.purposeTextView.text = "Bio"
                    cell.purposeTextView.textColor = UIColor.lightGrayColor()
                }
                
                return cell
                
            }
            
            
            
        case .EditProfileInformationSectionTypeContact:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(textFieldCellID, forIndexPath: indexPath) as! TextFieldTableViewCell
            
            
            
            switch EditContactTypes(rawValue: indexPath.row)! {
                
            case .EditContactTypePhone:
                
                if let phone = person.phoneNumber {
                    
                    cell.infoTextField.text = phone
                    
                } else {
                    
                    cell.infoTextField.placeholder = "Phone"
                    
                }
                
                return cell
                
            case .EditContactTypeEmail:
                
                cell.infoTextField.text = person.email
                
                return cell
                
            }
        
        }
    }
}

