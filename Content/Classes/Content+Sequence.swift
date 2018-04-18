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
    
    open func swap(from: Int, to: Int) {
        self.relation.swapAt(from, to)
    }
    
    open func move(from: Int, to: Int) {
        if from != to {
            self.relation.swapAt(from, to) // Doesn't allow use use content because of mutation
            self.delegate?.move(from: from, to: to)
        }
    }
    
    open func insert(contentsOf models: [Model], at index: Int = 0, animated: Bool = true, completion: @escaping () ->()) {
        self.delegate?.insert(models, index: index, animated: animated, completion: completion)
        self.adjustEmptyView()
    }
    
//    open func append(contentsOf models: [Model], animated: Bool = true) {
//        self.delegate?.insert(models, index: self.count, animated: animated)
//    }
    
    open func append(contentsOf models: [Model], animated: Bool = true, completion: (() ->())? = nil) {
        self.delegate?.insert(models, index: self.count, animated: animated, completion: completion)
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
    open func reload(_ models: [Model], animated: Bool = false) {
        self.delegate?.reload(models, animated: animated)
    }
    
    open func reload(_ models: Model..., animated: Bool = false) {
        self.delegate?.reload(models, animated: animated)
    }
    
    open func replace(_ models: Model..., animated: Bool = false) {
        fatalError("Not implemeted")
    }
    
//    open func reset(showEmptyView: Bool = false, adjustInfinite: Bool = false, completion: (() -> ())? = nil) {
//        let items = self.items
//        self.relation.removeAll()
//        self.append(contentsOf: items, animated: false) {
//            self.adjustEmptyView(hidden: !showEmptyView)
//            if adjustInfinite {
//                self.adjustInfiniteView(length: self.items.count)
//            }
//            completion?()
//        }
//    }
    
    open func reset(items: [Model] = [], showEmptyView: Bool = false, adjustInfinite: Bool = false, completion: (() -> ())? = nil) {
        self.relation.removeAll()

        if !items.isEmpty {
            self.relation.insert(contentsOf: items, at: self.count)
        }
        self.reload()
        self.currentErrorView?.removeFromSuperview()
        self.adjustEmptyView(hidden: !showEmptyView)
        if adjustInfinite {
            self.adjustInfiniteView(length: items.count)
        }
        completion?()
    }
}

extension Content: MutableCollection, BidirectionalCollection {
    //MARK: - MutableCollection & BidirectionalCollection impl
    open var startIndex: Int { return relation.startIndex }
    open var endIndex: Int { return relation.endIndex }
    
    open subscript (position: Int) -> Model {
        get { return relation[position] }
        set { relation[position] = newValue }
    }
    
    open subscript (range: Range<Int>) -> ArraySlice<Model> {
        get { return relation[range] }
        set { relation.replaceSubrange(range, with: newValue) }
    }
    
    open func index(after i: Int) -> Int { return relation.index(after: i) }
    open func index(before i: Int) -> Int { return relation.index(before: i) }
}
