//
//  ContentOf.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

open class ContentOf<Model: Equatable & Servicable, View: ViewDelegate, Cell: ContentCell>: Content<Model, View, Cell> where View: UIView {
    
    public override init(view: View, delegate: BaseDelegate<Model, View, Cell>? = nil, configuration: Configuration? = nil) {
        super.init(view: view, delegate: delegate, configuration: configuration)
        self.adapter = AdapterGenerator.generate()
    }
    
}
