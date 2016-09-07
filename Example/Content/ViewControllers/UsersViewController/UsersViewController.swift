//
//  UsersViewController.swift
//  Content
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Content
import AlamofireImage

protocol V {
    associatedtype _Model
//    associatedtype _View
//    associatedtype _Delegate
}

class UsersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var content: Content<User, UITableView, UserTableViewCell>!
 
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Users"
        
//        var c = Content<Equatable, UITableView, UserTableViewCell>()
        
        self.content = Content(view: self.tableView).onCellSetup({ (user, cell) in
            // Cell setup
            cell.textLabel?.text = user.name
            cell.imageView?.af_setImageWithURL(user.avatarURL)
        }).onSelect({ [weak self] (content, user, cell) in
            let viewController = UserViewController()
            viewController.user = user
            self?.navigationController?.pushViewController(viewController, animated: true)
        }).onLoad({ (content) in
            User.index({ content.fetch($0, error: nil) })
        }).onAction({ [unowned self] (content, model, cell, action) in
            if action == "posts" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let viewController = storyboard.instantiateViewControllerWithIdentifier("PostsViewController") as? PostsViewController {
                    viewController.user = model
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        })
        self.content.refresh()
    }
    
}