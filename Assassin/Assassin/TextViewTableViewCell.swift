//
//  TextViewTableViewCell.swift
//  Assassin
//
//  Created by Michael Sacks on 9/23/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit

//protocol TextViewTableViewCellDelegate {
//    
//    func textOnTextViewCellEntered(sender : TextViewTableViewCell)
//    
//}

class TextViewTableViewCell: UITableViewCell {

//    var delegate : TextViewTableViewCellDelegate?
    
    
    @IBOutlet weak var purposeTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func textViewDidEndEditing(textView: UITextView) {
//        
//        if let textViewCellDelegate = delegate {
//            
//            textViewCellDelegate.textOnTextViewCellEntered(self)
//            
//        }
//    }

}
