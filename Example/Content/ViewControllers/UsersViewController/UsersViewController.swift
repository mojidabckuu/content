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
        
        self.content = Content(view: self.tableView).on(cellSetup: { (user, cell) in
            cell.textLabel?.text = user.name
            cell.imageView?.af_setImage(withURL: user.avatarURL)
        }).on(select: { [weak self] (content, user, cell) in
            let viewController = UserViewController()
            viewController.user = user
            self?.navigationController?.pushViewController(viewController, animated: true)
        }).on(load: { (content) in
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
//                content.fetch([], error: nil)
//            })
            User.index({ content.fetch($0, error: nil) })
        }).on(action: { (content, user, cell, action) in
//            var items = content.items
//            items.remove(at: 0)
            if action == "posts" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: "PostsViewController") as? PostsViewController {
                    viewController.user = user
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }).on(cellDequeue: { (user) -> UserTableViewCell.Type? in
            if user.name == "name3" {
                return User2222TableViewCell.self
            }
            return nil
        })
    
        self.content.refresh()
    }
    
}
