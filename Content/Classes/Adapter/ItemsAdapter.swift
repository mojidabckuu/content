//
//  ItemsAdapter.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

open class ItemsAdapter<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: Adapter<Model, View, Cell> where View: UIView {
    
    public required init() {}
    
    public func set(_ items: [Model]) {
        self.items = items
    }
    
    public func set(_ sequence: AnySequence<Model>) {
        self.items = Array(sequence)
    }
    
    override open func apply(content: Content<Model, View, Cell>) -> Content<Model, View, Cell> {
        return content
    }
}
