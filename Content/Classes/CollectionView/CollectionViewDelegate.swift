//
//  CollectionViewDelegate.swift
//  Contents
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

extension UICollectionView: Scrollable {}

open class CollectionDelegate<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: BaseDelegate<Model, View, Cell>, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout where View: UIView {
 
    open var collectionView: UICollectionView { return self.content.view as! UICollectionView }
    
    open override var selectedItem: Model? {
        set {
            self.select(model: newValue)
        }
        get {
            guard let indexPath = self.collectionView.indexPathsForSelectedItems?.first else { return nil }
            return self.content.items[indexPath.row]
        }
    }
    
    open override var selectedItems: [Model]? {
        set {
            self.select(models: newValue)
        }
        get { return self.collectionView.indexPathsForSelectedItems?.map { self.content.items[$0.row] } }
    }
    
    open override var visibleItem: Model? {
        set {
            self.scroll(to: newValue)
        }
        get {
            guard let indexPath = self.collectionView.indexPathsForVisibleItems.first else { return nil }
            return self.content.items[indexPath.row]
        }
    }
    
    open override var visibleItems: [Model]? {
        set {
            self.scroll(to: newValue)
        }
        get { return self.collectionView.indexPathsForVisibleItems.map { self.content.items[$0.row] } }
    }
    
    //MARK: - Lifecycle
    public override init() {
        super.init()
    }
    
    override init(content: Content<Model, View, Cell>) {
        super.init(content: content)
    }
    
    // Select
    open override func select(model: Model?, animated: Bool = false, scrollPosition: ContentScrollPosition = .none) {
        guard let model = model else { return }
        if let index = self.content.items.index(of: model) {
            let indexPath = IndexPath(item: index, section: 0)
            let defaultScroll = scrollPosition == .none ? self.none : scrollPosition
            self.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition.collectionScroll)
        }
    }
    
    open override func select(models: [Model]?, animated: Bool = false, scrollPosition: ContentScrollPosition = .none) {
        guard let models = models else { return }
        for (i, model) in models.enumerated() {
            self.select(model: model, animated: animated, scrollPosition: i == 0 ? scrollPosition : self.none)
        }
    }
    
    //Scroll
    override func scroll(to model: Model?, at: ContentScrollPosition = .middle, animated: Bool = true) {
        guard let model = model else { return }
        if let index = self.content.items.index(of: model) {
            let indexPath = IndexPath(row: index, section: 0)
            let defaultScroll = at == .middle ? self.middle : at
            self.collectionView.scrollToItem(at: indexPath, at: at.collectionScroll, animated: true)
        }
    }
    
    /** Scrolls to first item only */
    override func scroll(to models: [Model]?, at: ContentScrollPosition = .middle, animated: Bool = true) {
        guard let model = models?.first else { return }
        self.scroll(to: model, at: at, animated: animated)
    }
    
    // Insert
    override open func insert(_ models: [Model], index: Int = 0) {
        let collectionView = self.collectionView
        self.collectionView.performBatchUpdates({
            self.content.items.insert(contentsOf: models, at: index)
            let indexPaths = self.indexPaths(models)
            collectionView.insertItems(at: indexPaths)
        }, completion: nil)
    }
    
    //Delete
    open override func delete(_ models: [Model]) {
        var indexes = models
            .flatMap { self.content.items.index(of: $0) }
            .map {IndexPath(row: $0, section: 0)}
        let collectionView = self.collectionView
        let content = self.content
        self.collectionView.performBatchUpdates({
            indexes.forEach { content?.items.remove(at: $0.row) }
            collectionView.deleteItems(at: indexes)
        }, completion: nil)
    }
    
    //Reload
    open override func reload(_ models: [Model], animated: Bool) {
        let indexes = self.indexPaths(models)
        let collectionView = self.collectionView
        if animated {
            collectionView.performBatchUpdates({
                collectionView.reloadItems(at: indexes)
            }, completion: nil)
        } else {
            collectionView.reloadItems(at: indexes)
        }
    }
    
    // Registration
    override open func registerCell(_ reuseIdentifier: String, nib: UINib) {
        self.collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    //MARK: - UICollectionView delegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! Cell
        self.content.actions.onSelect?(self.content, self.content.items[indexPath.row], cell)
        if self.content.configuration.autoDeselect {
            self.collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? Cell {
            self.content.actions.onDeselect?(self.content, self.content.items[indexPath.row], cell)
        }
    }
    
    //MARK: - UICollectionView data
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.content.items.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.collectionView(collectionView, cellForItemAt: indexPath, with: Cell.identifier)
    }
    
    //TODO: It is a workaround to achieve different rows for dequeue.
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, with identifier: String) -> UICollectionViewCell {
        let item = self.content.items[indexPath.row]
        let id = self.content.callbacks.onDequeueBlock?(item)?.identifier ?? identifier
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)
        if var cell = collectionViewCell as? Cell {
            cell.raiser = self.content
            self.content.callbacks.onCellSetupBlock?(item, cell)
        }
        return collectionViewCell
    }
    
    // CollectionView float layout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = self.content.callbacks.onLayout?(self.content, self.content.items[indexPath.row]) {
            return size
        }
//        print(#file + " You didn't specify size block. Use on(:layout) chain.")
        return CGSize(width: 40, height: 40)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let page = Int(scrollView.contentOffset.x / pageWidth)
        self.content.callbacks.onItemChanged?(self.content, self.content.items[page], page)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.content.scrollCallbacks.onDidScroll?(self.content)
    }
    
    //MARK: - Utils
    
    private var none : ContentScrollPosition {
        let position: ContentScrollPosition = (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .vertical ? .left : .top
        return position
    }
    
    private var middle : ContentScrollPosition {
        let position: ContentScrollPosition = (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .vertical ? .centeredVertically : .centeredHorizontally
        return position
    }
    
    override open func indexPath(_ cell: Cell) -> IndexPath? {
        if let collectionViewCell = cell as? UICollectionViewCell {
            return self.collectionView.indexPath(for: collectionViewCell)
        }
        return nil
    }
}
