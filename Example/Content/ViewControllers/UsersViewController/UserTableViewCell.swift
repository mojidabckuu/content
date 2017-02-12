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
    
    @IBAction func posts(_ sender: AnyObject) {
        self.raiser?.raise("posts", sender: self)
    }
    
}

class User2222TableViewCell: UserTableViewCell {
    
    @IBAction override func posts(_ sender: AnyObject) {
        print("asjdgjaskgdjasgdjhsagd")
    }
    
}
