//
//  Relation.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 26/11/2017.
//

import Foundation

public typealias ContentRelation = Relation

open class Relation<Model: Equatable>: MutableCollection, BidirectionalCollection, RangeReplaceableCollection {
    public internal(set) var offset: Any?
    
    public var hasMore: Bool { return offset != nil }
    
    public private(set) var items: [Model] = []
    public private(set) var chunks: [Relation<Model>] = []
    
    public required init() {}
    public convenience init(_ items: [Model], offset: Any? = nil) {
        self.init()
        self.items = items
        self.offset = offset
    }
    
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
    open func append(_ newElement: Model) {
        items.append(newElement)
    }
    
    open func append<S : Sequence>(contentsOf newElements: S) where S.Iterator.Element == Model {
        items.append(contentsOf: newElements)
    }
    
    open func append<S : Sequence>(contentsOf newElements: S, offset: Any?) where S.Iterator.Element == Model {
        self.append(contentsOf: newElements)
        self.offset = offset
    }
    
    open func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == Model {
        items.replaceSubrange(subRange, with: newElements)
    }
    
    open func removeAll(keepingCapacity keepCapacity: Bool = false) {
        items.removeAll(keepingCapacity: keepCapacity)
    }
    
    open func append(relation: Relation) {
        self.chunks.append(relation)
        self.items.append(contentsOf: relation.items)
        self.offset = relation.offset
    }
}
