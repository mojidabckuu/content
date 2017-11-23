//
//  Content+Sequence.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 23/11/2017.
//

import Foundation

//TODO: Conform to RangeReplaceableCollection
extension Content {
    //MARK: - Management
    open func insert(_ newElement: Model, at index: Int = 0, animated: Bool = true) {
        self.delegate?.insert([newElement], index: index, animated: animated)
        self.adjustEmptyView()
    }
    
    open func insert(_ models: [Model], at index: Int = 0) {
        self.insert(contentsOf: models, at: index, animated: true)
    }
    
    open func insert(contentsOf models: [Model], at index: Int = 0, animated: Bool = true) {
        self.delegate?.insert(models, index: index, animated: animated)
        self.adjustEmptyView()
    }
    
    open func append(contentsOf models: [Model], animated: Bool = true) {
        self.delegate?.insert(models, index: self.count, animated: animated)
    }
    
    open func append(_ models: Model..., animated: Bool = true) {
        self.delegate?.insert(models, index: self.count, animated: animated)
    }
    
    // Delete
    open func delete(items models: [Model]) {
        self.delegate?.delete(models)
        self.adjustEmptyView()
    }
    open func delete(_ models: Model...) {
        self.delegate?.delete(models)
        self.adjustEmptyView()
    }
    //Reload
    open func reload(_ models: Model..., animated: Bool = false) {
        self.delegate?.reload(models, animated: animated)
    }
    
    open func replace(_ models: Model..., animated: Bool = false) {
        fatalError("Not implemeted")
    }
    
    open func reset(items: [Model] = [], showEmptyView: Bool = false, adjustInfinite: Bool = false) {
        self.adapter.items = items
        self.adjustEmptyView(hidden: !showEmptyView)
        if adjustInfinite {
            self.adjustInfiniteView(length: items.count)
        }
        self.reloadData()
    }
}

extension Content: MutableCollection, BidirectionalCollection {
    //MARK: - MutableCollection & BidirectionalCollection impl
    open var startIndex: Int { return adapter.startIndex }
    open var endIndex: Int { return adapter.endIndex }
    
    open subscript (position: Int) -> Model {
        get { return adapter[position] }
        set { adapter[position] = newValue }
    }
    
    open subscript (range: Range<Int>) -> ArraySlice<Model> {
        get { return adapter[range] }
        set { adapter.replaceSubrange(range, with: newValue) }
    }
    
    open func index(after i: Int) -> Int { return adapter.index(after: i) }
    open func index(before i: Int) -> Int { return adapter.index(before: i) }
}
