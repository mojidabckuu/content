//
//  CollectionViewDelegate.swift
//  Contents
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

public class CollectionDelegate<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: BaseDelegate<Model, View, Cell>, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
 
    var collectionView: UICollectionView { return self.content.view as! UICollectionView }
    
    override init(content: Content<Model, View, Cell>) {
        super.init(content: content)
    }
 
    // Insert
    
    override func insert(models: [Model], index: Int) {
        self.collectionView.insertItemsAtIndexPaths(self.indexPaths(models))
    }
        
    override func indexPath(cell: Cell) -> NSIndexPath? {
        if let collectionViewCell = cell as? UICollectionViewCell {
            return self.collectionView.indexPathForCell(collectionViewCell)
        }
        return nil
    }
    
    // Registration
    
    override func registerCell(reuseIdentifier: String, nib: UINib) {
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    // UICollectionView delegate
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! Cell
        self.content.actions.onSelect?(self.content, self.content.items[indexPath.row], cell)
        if self.content.configuration.autoDeselect {
            self.collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! Cell
        self.content.actions.onDeselect?(self.content, self.content.items[indexPath.row], cell)
        if self.content.configuration.autoDeselect {
            self.collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        }
    }
    
    // UICollectionView data
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.content.items.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.identifier, forIndexPath: indexPath)
        if var cell = collectionViewCell as? Cell {
            cell.raiser = self.content
            self.content.callbacks.onCellSetupBlock?(self.content.items[indexPath.row], cell)
        }
        return collectionViewCell
    }
    
    // CollectionView float layout
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let size = self.content.callbacks.onLayout?(self.content, self.content.items[indexPath.row]) {
            return size
        }
        print(#file + " You didn't specify size block. Use onLayout chain.")
        return CGSize(width: 40, height: 40)
    }
}