//
//  PostsViewController.swift
//  Content
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Content

class PostsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User!
    
    var content: Content<Post, UICollectionView, PostCollectionViewCell>!
    
    //MARK: - 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.content = Content(view: self.collectionView).onSetup({ (content) in
            let collectionView = content.view
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = 2
                layout.minimumInteritemSpacing = 0
                layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
                layout.scrollDirection = .Vertical
            }
        }).onCellSetup({ (model, cell) in
           cell.textLabel.text = model.text
        }).onLoad({ [unowned self] (content) in
            self.user.posts({ content.fetch($0, error: nil) })
        }).onLayout({ (content, model) -> CGSize in
            let screenSize = UIScreen.mainScreen().bounds.size
            return CGSize(width: screenSize.width, height: 400)
        }).onSelect({ (contnet, model, cell) in
            print(model)
        })
        self.content.refresh()
    }
}
