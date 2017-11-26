//
//  Relation.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 26/11/2017.
//

import Foundation

typealias ContentRelation = Relation

open class Relation<Model: Equatable>: MutableCollection, BidirectionalCollection, RangeReplaceableCollection {
    var offset: Any?
    
    public private(set) var items: [Model] = []
    public private(set) var chunks: [Relation<Model>] = []
    
    public required init() {}
    
    open func reset(items: [Model]) {
        self.removeAll()
        self.chunks.removeAll()
        self.append(contentsOf: items)
    }
    
    // MutableCollection, BidirectionalCollection
    public var startIndex: Int { return items.startIndex }
    public var endIndex: Int { return items.endIndex }
    
    public subscript (position: Int) -> Model {
        get { return items[position] }
        set { items[position] = newValue }
    }
    
    public subscript (range: Range<Int>) -> ArraySlice<Model> {
        get { return items[range] }
        set { items.replaceSubrange(range, with: newValue) }
    }
    
    public func index(after i: Int) -> Int { return items.index(after: i) }
    public func index(before i: Int) -> Int { return items.index(before: i) }
    
    // RangeReplaceableCollection
    public func append(_ newElement: Model) {
        items.append(newElement)
    }
    
    public func append<S : Sequence>(contentsOf newElements: S) where S.Iterator.Element == Model {
        items.append(contentsOf: newElements)
    }
    
    public func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == Model {
        items.replaceSubrange(subRange, with: newElements)
    }
    
    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        items.removeAll(keepingCapacity: keepCapacity)
    }
    
    open func append(relation: Relation) {
        self.chunks.append(relation)
        self.items.append(contentsOf: relation.items)
        self.offset = relation.offset
    }
}

////TODO: Move to separated util
//extension Content where Model: Mappable {
//
//    open func fetch(relation: Relation<Model>?, error: Error? = nil) {
//        if let relation = relation {
//            self.offset = relation.offset
//        }
//        self.fetch(relation?.items, error: error)
//    }
//
//    @discardableResult
//    func on(load block: @escaping ((_ content: Content<Model, View, Cell>) -> Promise<Relation<Model>>)) -> Content<Model, View, Cell> {
//        self.on(load: { (content) in
//            block(self).then(execute: { (relation) -> Void in
//                self.fetch(relation: relation)
//            }).catch(execute: { (error) in
//                self.fetch(error: error)
//            })
//        })
//        return self
//    }
//}


