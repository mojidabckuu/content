//
//  Adapter.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

//public protocol AdapterView: ViewDelegate where Self: UIView {}
//public protocol AdapterModel: Equatable, Servicable {
//
//}
//
//public protocol _Adapter {
//    associatedtype Model: AdapterModel
//    associatedtype View: AdapterView
//    associatedtype Cell: ContentCell
//
//    func apply(content: Content<Model, View, Cell>) -> Content<Model, View, Cell>
//}

open class Adapter<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    var offset: Any?
    internal var items: [Model] = []
    
    public required init() {}
    
    open func apply(content: Content<Model, View, Cell>) -> Content<Model, View, Cell> { fatalError("Not implemented") }
}

extension Adapter: MutableCollection, BidirectionalCollection {
    //    extension Relation:  {
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


extension Adapter: RangeReplaceableCollection {
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
