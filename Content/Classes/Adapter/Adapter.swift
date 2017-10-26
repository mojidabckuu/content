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

open class Adapter<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: MutableCollection, BidirectionalCollection, RangeReplaceableCollection where View: UIView {
    
    var offset: Any?
    internal var items: [Model] = []
    
    public required init() {}
    
    open func apply(content: Content<Model, View, Cell>) -> Content<Model, View, Cell> { fatalError("Not implemented") }

    //MARK: - MutableCollection & BidirectionalCollection impl
    open var startIndex: Int { return items.startIndex }
    open var endIndex: Int { return items.endIndex }
    
    open subscript (position: Int) -> Model {
        get { return items[position] }
        set { items[position] = newValue }
    }
    
    open subscript (range: Range<Int>) -> ArraySlice<Model> {
        get { return items[range] }
        set { items.replaceSubrange(range, with: newValue) }
    }
    
    open func index(after i: Int) -> Int { return items.index(after: i) }
    open func index(before i: Int) -> Int { return items.index(before: i) }
    
    //MARK: - RangeReplaceableCollection impl
    open func append(_ newElement: Model){
        items.append(newElement)
    }
    
    open func append<S : Sequence>(contentsOf newElements: S) where S.Iterator.Element == Model {
        items.append(contentsOf: newElements)
    }
    
    open func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == Model {
        items.replaceSubrange(subRange, with: newElements)
    }
    
    open func removeAll(keepingCapacity keepCapacity: Bool = false) {
        items.removeAll(keepingCapacity: keepCapacity)
    }
}
