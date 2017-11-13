//
//  ContentOf.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

open class ContentOf<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: Content<Model, View, Cell> where View: UIView {
    
    private var _adapter = RelationAdapter<Model, View, Cell>()
    override var adapter: Adapter<Model, View, Cell> {
        get { return _adapter }
        set { }
    }
    
    public override init(view: View, delegate: BaseDelegate<Model, View, Cell>? = nil, configuration: Configuration? = nil, setup block: ((_ content: Content<Model, View, Cell>) -> Void)? = nil) {
        super.init(view: view, delegate: delegate, configuration: configuration, setup: block)
    }
    
//    open func fetch(_ relation: Relation<Model>?, error: Error?) {
//        if let relation = relation {
//            self.offset = relation.offset
//            _adapter.append(contentsOf: relation)
//        }
//        self.fetch(relation?.items, error: error)
//    }
    
}

extension Content {
    open func fetch(_ relation: Relation<Model>?, error: Error?) {
        if let relation = relation {
            self.offset = relation.offset
//            _adapter.append(contentsOf: relation)
        }
        self.fetch(relation?.items, error: error)
    }
}
