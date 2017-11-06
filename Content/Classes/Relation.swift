//
//  Relation.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 24/10/2017.
//

import Foundation

public protocol _Model {
    init()
    
    static var modelName: String { get }
    static var modelsName: String { get }
    
    static var resourceName: String { get }
    static var resourcesName: String { get }
}

public extension _Model {
//    static var modelName: String { return "" }
//    static var modelsName: String { return "" }
}

public protocol Cancellable {
    func cancel()
}

open class Request<Model>: Cancellable {
    open var identifier: Int { fatalError("Not implemented") }
    
    public init() {}
    // Creates a new model
    open func map(_ completion: @escaping ([Model]) -> ()) -> Self { fatalError("Not implemented") }
    open func obtain(_ completion: @escaping (Model) -> ()) -> Self { fatalError("Not implemented") }
    // Updates curent model
    open func flush(_ completion: @escaping (Model) -> ()) -> Self { fatalError("Not implemented") }
    //
    open func `catch`(_ completion: @escaping ((Error?) -> ())) -> Self { fatalError("Not implemented") }
    
    open func cancel() {
        fatalError("Not implemented")
    }
}
public typealias RelationRequest = Request

public protocol _Servicable {}

public protocol Servicable: _Model, _Servicable {
    static var service: Service<Self> { get }
}

public extension Servicable {
    static var service: Service<Self> { fatalError("Not implemented") }
}

open class Service<Model: _Model> {
    public init() {}
    
    open func index(params: [String: Any] = [:]) -> RelationRequest<Model> { fatalError("Not implemented") }
    open func create(params: [String: Any]) -> RelationRequest<Model> { fatalError("Not implemented") }
//    open func show(params: [String: Any]) -> RelationRequest<Model> { fatalError("Not implemented") }
    open func patch(model: Model, params: [String: Any]) -> RelationRequest<Model> { fatalError("Not implemented") }
    open func put(model: Model, params: [String: Any]) -> RelationRequest<Model> { fatalError("Not implemented") }
    open func show(model: Model, params: [String: Any] = [:]) -> RelationRequest<Model> { fatalError("Not implemented") }
    open func delete(model: Model, params: [String: Any] = [:]) -> RelationRequest<Model> { fatalError("Not implemented") }
    open func delete(params: [String: Any]) -> RelationRequest<Model> { fatalError("Not implemented") }
}

open class Chunk<Model> {
    public private(set) var items: [Model] = []
    public private(set) var offset: Any?
    init(items: [Model], offset: Any? = nil) {
        self.items = items
        self.offset = offset
    }
}

open class Relation<Model: Servicable> {
    fileprivate var _items: [Model] = []
    
    var items: [Model] { return _items }
    var chunks: [Chunk<Model>] { return [] }
    
    var offset: Any? // offset starting from the last item
    var total: Int = 0 // total expected count
    var length: Int = 0 // last page received count
    
    public var modelClass: Model.Type { return Model.self }
    
    var parameters: [String: Any] = [:]
    
    required public init() {}

    func index() -> Request<Model> {
        return Model.service.index(params: self.parameters)
    }
    
    func create(attributes: [String: Any]) -> Request<Model> {
        return Model.service.create(params: parameters)
    }
    
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

extension Relation {
    public func update(attributes: [String: Any]) {
//        let map = Map(mappingType: .fromJSON, JSON: attributes)
//        self.mapping(map: map)
    }
    
//    public func mapping(map: Map) {
//        newItems <- map[Model.modelsName]
//        newItems <- map["\(Model.modelsName).items"]
//        offset <- map["\(Model.modelsName).\(RelationConfiguration.Keys.offset)"]
//        total  <- map["\(Model.modelsName).\(RelationConfiguration.Keys.total)"]
//        length <- map["\(Model.modelsName).\(RelationConfiguration.Keys.length)"]
//    }
}

open class RelationOf<Model: Servicable, Parent>: Relation<Model> {

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
    public var startIndex: Int { return _items.startIndex }
    public var endIndex: Int { return _items.endIndex }
    
    public subscript (position: Int) -> Model {
        get { return _items[position] }
        set { _items[position] = newValue }
    }
    
    public subscript (range: Range<Int>) -> ArraySlice<Model> {
        get { return _items[range] }
        set { _items.replaceSubrange(range, with: newValue) }
    }
    
    public func index(after i: Int) -> Int { return _items.index(after: i) }
    public func index(before i: Int) -> Int { return _items.index(before: i) }
}

extension Relation: RangeReplaceableCollection {
    public func append(_ newElement: Model){
        _items.append(newElement)
    }
    
    public func append<S : Sequence>(contentsOf newElements: S) where S.Iterator.Element == Model {
        _items.append(contentsOf: newElements)
    }
    
    public func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == Model {
        _items.replaceSubrange(subRange, with: newElements)
    }
    
    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        _items.removeAll(keepingCapacity: keepCapacity)
    }
}

