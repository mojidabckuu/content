//
//  CollectionView+Extensions.swift
//  Contents
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

extension UICollectionView: ViewDelegate {}
public extension UICollectionView {
    var contentDelegate: AnyObject? {
        get { return self.delegate }
        set { self.delegate = newValue as? UICollectionViewDelegate }
    }
    var contentDataSource: AnyObject? {
        get { return self.dataSource }
        set { self.dataSource = newValue as? UICollectionViewDataSource }
    }
    
    func set(contentOffset: CGPoint) {
        self.contentOffset = contentOffset
    }
}

extension UICollectionViewCell: _Cell {}
