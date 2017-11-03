//
//  PostsViewController.swift
//  Content
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Content
import PromiseKit

class CCollectionView: UICollectionView {
    
    deinit {
        print("Deinit CCollectionView")
    }
}

class PostsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User!
    
    var content: Content<Post, UICollectionView, PostCollectionViewCell>!
    
    //MARK: - 
    
    
    deinit {
        print("Controller deinit")
    }
    
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
        }).on(load: { [weak self] (content) in
            let weakC = content
//            self?.user.posts({ (posts) in
//
//            })
            Promise<[Post]>.init(resolvers: { (fulfill, reject) in
                self?.user.posts({ (posts) in
                    fulfill(posts)
                })
            }).then(execute: { (posts) -> Void in
//                let items = content.items
//                print(items.count)
                content.fetch(posts, error: nil)
            })
//            self?.user.posts({ content.fetch($0, error: nil) })
        }).on(layout: { (content, post) -> CGSize in
            let conte = content
            let screenSize = UIScreen.main.bounds.size
            return CGSize(width: screenSize.width, height: 400)
        }).on(select: { (content, model, cell) in
            print(model)
        })
        self.content.refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.content = nil
    }
}
