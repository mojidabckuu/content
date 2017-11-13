//
//  RelationAdapter.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

open class RelationAdapter<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: Adapter<Model, View, Cell>  where View: UIView {
    
    public private(set) var relation = Relation<Model>()
    
    internal override var items: [Model] {
        get { return self.relation.items }
        set {
            self.relation.removeAll()
            self.relation.append(contentsOf: newValue)
        }
    }
    
    override open func apply(content: Content<Model, View, Cell>) -> Content<Model, View, Cell> {
//        return content.on(load: { (content) in
//            let _ = self.relation.index()
            // TODO: Add fetch
//        })
        return content
    }

    //MARK: -
    open override var startIndex: Int { return relation.startIndex }
    open override var endIndex: Int { return relation.endIndex }
    
    open override subscript (position: Int) -> Model {
        get { return relation[position] }
        set { relation[position] = newValue }
    }
    
    open override subscript (range: Range<Int>) -> ArraySlice<Model> {
        get { return relation[range] }
        set { relation.replaceSubrange(range, with: newValue) }
    }
    
    open override func index(after i: Int) -> Int { return relation.index(after: i) }
    open override func index(before i: Int) -> Int { return relation.index(before: i) }
    
    //MARK: -
    open override func append(_ newElement: Model) {
        relation.append(newElement)
    }
    
    open override func append<S : Sequence>(contentsOf newElements: S) where S.Iterator.Element == Model {
        relation.append(contentsOf: newElements)
    }
    
    open override func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == Model {
        relation.replaceSubrange(subRange, with: newElements)
    }
    
    open override func removeAll(keepingCapacity keepCapacity: Bool = false) {
        relation.removeAll(keepingCapacity: keepCapacity)
    }
}

extension RelationAdapter {
    open func append(contentsOf relation: Relation<Model>) {
        self.relation.append(contentsOf: relation.items)
        self.relation.offset = relation.offset
    }
}

