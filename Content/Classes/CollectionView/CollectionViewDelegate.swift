//
//  CollectionViewDelegate.swift
//  Contents
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

open class CollectionDelegate<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: BaseDelegate<Model, View, Cell>, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
 
    var collectionView: UICollectionView { return self.content.view as! UICollectionView }
    
    override init(content: Content<Model, View, Cell>) {
        super.init(content: content)
    }
 
    // Insert
    
    override func insert(_ models: [Model], index: Int) {
        self.collectionView.insertItems(at: self.indexPaths(models))
    }
        
    override func indexPath(_ cell: Cell) -> IndexPath? {
        if let collectionViewCell = cell as? UICollectionViewCell {
            return self.collectionView.indexPath(for: collectionViewCell)
        }
        return nil
    }
    
    // Registration
    
    override func registerCell(_ reuseIdentifier: String, nib: UINib) {
        self.collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    // UICollectionView delegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! Cell
        self.content.actions.onSelect?(self.content, self.content.items[(indexPath as NSIndexPath).row], cell)
        if self.content.configuration.autoDeselect {
            self.collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! Cell
        self.content.actions.onDeselect?(self.content, self.content.items[(indexPath as NSIndexPath).row], cell)
        if self.content.configuration.autoDeselect {
            self.collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    // UICollectionView data
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.content.items.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath)
        if var cell = collectionViewCell as? Cell {
            cell.raiser = self.content
            self.content.callbacks.onCellSetupBlock?(self.content.items[(indexPath as NSIndexPath).row], cell)
        }
        return collectionViewCell
    }
    
    // CollectionView float layout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = self.content.callbacks.onLayout?(self.content, self.content.items[(indexPath as NSIndexPath).row]) {
            return size
        }
        print(#file + " You didn't specify size block. Use onLayout chain.")
        return CGSize(width: 40, height: 40)
    }
}
