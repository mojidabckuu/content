//
//  RelationAdapter.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

open class RelationAdapter<Model: Equatable & Servicable, View: ViewDelegate, Cell: ContentCell>: Adapter<Model, View, Cell>  where View: UIView {
    
    public private(set) lazy var relation = {
        //        let dynamic = type(of: Model) as! Servicable
        Relation<Model>()
    }()
    
    public override var items: [Model] {
        get { return self.relation.items }
        set {
            self.relation.removeAll()
            self.relation.append(contentsOf: newValue)
        }
    }
    
    override open func apply(content: Content<Model, View, Cell>) -> Content<Model, View, Cell> {
        return content.on(load: { (content) in
            let _ = self.relation.index()
            // TODO: Add fetch
        })
    }
}
