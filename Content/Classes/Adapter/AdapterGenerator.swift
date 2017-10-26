//
//  AdapterGenerator.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

open class AdapterGenerator {
    
    static public func generate<Model: Servicable, View: ViewDelegate & UIView, Cell: ContentCell>() -> RelationAdapter<Model, View, Cell> {
        return RelationAdapter()
    }
    
    static public func generate<Model: Equatable, View: ViewDelegate & UIView, Cell: ContentCell>() -> ItemsAdapter<Model, View, Cell> {
        return ItemsAdapter()
    }
    
}
