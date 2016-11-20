//
//  ViewDelegate.swift
//  Contents
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

public protocol Scrollable {}
extension Scrollable {
    var scrollView: UIScrollView { return self as! UIScrollView }
}

public protocol ViewDelegate: Scrollable {
    var contentDelegate: AnyObject? { get set }
    var contentDataSource: AnyObject? { get set }
    
    func reloadData()
}

open class BaseDelegate<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: NSObject where View: UIView {
    open var content: Content<Model, View, Cell>
    
    public init(content: Content<Model, View, Cell>) {
        self.content = content
    }
    
    // Setup
    func setup() {}
    
    //
    func insert(_ models: [Model], index: Int = 0) {}
    func delete(_ models: [Model]) { }
    func reload() {
        self.content.view.reloadData()
    }
    func reload(_ models: [Model]) {}
    
    func indexPaths(_ models: [Model]) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for model in models {
            if let index = self.content.items.index(of: model) {
                let indexPath = IndexPath(row: Int(index), section: 0)
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
    }
    
    //
    func registerCell(_ reuseIdentifier: String, class: AnyClass) {}
    func registerCell(_ reuseIdentifier: String, nib: UINib) {}
    
    func dequeu() -> Cell? { return nil }
    func indexPath(_ cell: Cell) -> IndexPath? { return nil }    
}
