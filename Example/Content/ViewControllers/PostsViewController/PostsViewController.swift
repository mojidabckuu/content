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
        
        self.content = Content(view: self.collectionView).on(setup: { (content) in
            let collectionView = content.view
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = 2
                layout.minimumInteritemSpacing = 0
                layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
                layout.scrollDirection = .vertical
            }
        }).on(cellSetup: { (model, cell) in
           cell.textLabel.text = model.text
        }).on(load: { (content) in
            self.user.posts({ content.fetch($0, error: nil) })
        }).on(layout: { (contnet, post) -> CGSize in
            let screenSize = UIScreen.main.bounds.size
            return CGSize(width: screenSize.width, height: 400)
        }).on(select: { (content, model, cell) in
            print(model)
        })
        self.content.refresh()
    }
}
