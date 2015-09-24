//
//  NamePhotoTableViewCell.swift
//  Assassin
//
//  Created by Michael Sacks on 9/23/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit
//
//protocol NamePhotoTableViewCellDelegate {
//    
//    func updateTemporaryPersonWithTextField(sender : NamePhotoTableViewCell)
//    
//}

class NamePhotoTableViewCell: UITableViewCell {

//    var delegate : NamePhotoTableViewCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var imageButton: UIButton!
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func textFieldDidEndEditing(textField: UITextField) {
//        
//        if let namePhotoCellDelegate = delegate {
//            
//            namePhotoCellDelegate.updateTemporaryPersonWithTextField(self)
//            
//        }
//    }

    @IBAction func imageButtonTapped(sender: UIButton) {
    }
}
