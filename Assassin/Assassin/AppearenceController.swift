//
//  AppearenceController.swift
//  AssassinCocoa
//
//  Created by Anne Tessier on 9/24/15.
//  Copyright © 2015 Michael Sacks. All rights reserved.
//

import UIKit

class AppearenceController: NSObject {
    
   static let purpleColor : UIColor = UIColor(red: 112/255.0, green: 41/255.0, blue: 99/255.0, alpha: 1.0)
    static let tealColor : UIColor = UIColor(red: 120/255.0, green: 195/255.0, blue: 168/255.0, alpha: 1.0)
    
    static func initializeAppearence() {
        
        UIButton.appearance().backgroundColor = purpleColor
        UIButton.appearance().setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
//        UIBarButtonItem.appearance().tintColor = tealColor
        
        
        //let backImage =
        
//        UIBarButtonItem.appearance().setBackButtonBackgroundImage(backImage, forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        
        //images to get
        //-back button arrow
        //Assassin full word w/ A icon
        //Assassin icon only
        //picture placeholder
        //picture placeholder w/ select image text
        
        
    }
    
    
    
    

}
