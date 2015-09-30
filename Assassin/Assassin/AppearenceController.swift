//
//  AppearenceController.swift
//  AssassinCocoa
//
//  Created by Anne Tessier on 9/24/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit

class AppearenceController: NSObject {
    
    static let purpleColor : UIColor = UIColor(red:115/255.0, green:57/255.0, blue:171/255.0, alpha:1.0)
    static let tealColor : UIColor = UIColor(red: 120/255.0, green: 195/255.0, blue: 168/255.0, alpha: 1.0)
    
    
    static let bigText : UIFont = UIFont.systemFontOfSize(20, weight: UIFontWeightBold)
    static let mediumBigText : UIFont = UIFont.systemFontOfSize(17, weight: UIFontWeightMedium)
    static let mediumSmallText : UIFont = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
    static let tinyText : UIFont = UIFont.systemFontOfSize(11, weight: UIFontWeightUltraLight)
    
    static func initializeAppearence() {
        
        UIButton.appearanceWhenContainedInInstancesOfClasses([LoginViewController.self]).backgroundColor = purpleColor
        UIButton.appearanceWhenContainedInInstancesOfClasses([LoginViewController.self]).setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)

        UIButton.appearanceWhenContainedInInstancesOfClasses([RegisterUserViewController.self]).backgroundColor = purpleColor
        UIButton.appearanceWhenContainedInInstancesOfClasses([RegisterUserViewController.self]).setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        UIBarButtonItem.appearance().tintColor = tealColor
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        
        UISegmentedControl.appearance().tintColor = tealColor

        
        if let backImage = UIImage(named: "backArrow") {
            
            let backImageWithInsets = backImage.resizableImageWithCapInsets(UIEdgeInsetsMake(1.0, 40.0, 1.0, 40.0))
            UIBarButtonItem.appearance().setBackButtonBackgroundImage(backImageWithInsets, forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(50000, 500000), forBarMetrics: UIBarMetrics.Default)
        }
        
        
        

       
            
        }
    
    static func getHeightOfTextWithFont(textString : String, font : UIFont, view: UIView) -> CGFloat {
        
        var textHeight = textString.boundingRectWithSize(CGSize(width: view.frame.size.width - 10, height: CGFloat.max),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil).size.height
        
        textHeight += 20
        
        return textHeight
        
    }
    
        //images to get
        //Assassin full word w/ A icon
}
