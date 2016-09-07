//
//  UserTableViewCell.swift
//  Content
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Content

class UserTableViewCell: UITableViewCell, ContentCell {

    var raiser: ActionRaiser?
    
    //MARK: - User interaction
    
    @IBAction func posts(sender: AnyObject) {
        self.raiser?.raise("posts", sender: self)
    }
    
}
