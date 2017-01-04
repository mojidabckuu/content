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

class UsersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var content: Content<User, UITableView, UserTableViewCell>!
 
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Users"
        self.tableView.isEditing = true
        let delegate = TableDelegate<User, UITableView, UserTableViewCell>()
        self.content = Content(view: self.tableView, delegate: delegate, configuration: Configuration.regular).on(cellSetup: { (user, cell) in
            cell.textLabel?.text = user.name
            cell.imageView?.af_setImage(withURL: user.avatarURL)
        }).on(select: { [weak self] (contnet, user, cell) in
            let viewController = UserViewController()
            viewController.user = user
            self?.navigationController?.pushViewController(viewController, animated: true)
        }).on(load: { (content) in
            User.index({ content.fetch($0, error: nil) })
        }).on(action: { (content, user, cell, action) in
            if action == "posts" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: "PostsViewController") as? PostsViewController {
                    viewController.user = user
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        })
    
        self.content.refresh()
    }
    
}
