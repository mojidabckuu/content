//
//  Relation.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 24/10/2017.
//

import Foundation

open class Chunk<Model> {
    public private(set) var items: [Model] = []
    public private(set) var offset: Any?
    init(items: [Model], offset: Any? = nil) {
        self.items = items
        self.offset = offset
    }
}

open class Relation<Model> {
    public fileprivate(set) var items: [Model]
    
    var chunks: [Chunk<Model>] { return [] }
    
    public var offset: Any? // offset starting from the last item
    var total: Int = 0 // total expected count
    var length: Int = 0 // last page received count
    
    public var modelClass: Model.Type { return Model.self }
    
    var parameters: [String: Any] = [:]
    
    required public init() {
        items = []
    }
    public init(_ items: [Model], offset: Any? = nil) {
        self.items = items
        self.offset = offset
    }

//    func index() -> Request<Model> {
//        return Model.service.index(params: self.parameters) as! Request<Model>
//    }
//
//    func create(attributes: [String: Any]) -> Request<Model> {
//        return Model.service.create(params: parameters) as! Request<Model>
//    }
    
    @discardableResult
    func `where`(_ parameters: [String: Any]) -> Self {
        self.parameters = parameters
        return self
    }
    
    func reset() {
        self.offset = nil
        self.total = 0
    }
}

open class RelationOf<Model, Parent>: Relation<Model> {

    fileprivate var _parent: Parent?

    open var parent: Parent? { return _parent }

    required public init() {
        super.init()
    }

    init(with parent: Parent? = nil) {
        super.init()
        _parent = parent
    }
    
//    init(parent: Parent?, index: @escaping IndexBlock, create: CreateBlock? = nil) {
//        super.init(index: index, create: create)
//        _parent = parent
//    }
//
//    override func create(attributes: [String : Any]) -> Request<Model> {
//        var attr = attributes
//        if let parent = self.parent {
//            attr["parent"] = parent
//        }
//        return super.create(attributes: attr)
//    }
}

extension Relation: MutableCollection, BidirectionalCollection {
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
}

// TOOD: Is it required?
extension Relation: RangeReplaceableCollection {
    public func append(_ newElement: Model){
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
}

