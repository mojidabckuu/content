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
    open var content: Content<Model, View, Cell>!
    
    public override init() {
        super.init()
    }
    
    init(content: Content<Model, View, Cell>) {
        self.content = content
    }
    
    // Setup
    open func setup() {}
    
    //
    open func insert(_ models: [Model], index: Int = 0) {}
    open func delete(_ models: [Model]) { }
    open func reload() {
        self.content.view.reloadData()
    }
    open func reload(_ models: [Model], animated: Bool) {}
    
    open func indexPaths(_ models: [Model]) -> [IndexPath] {
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
    open func registerCell(_ reuseIdentifier: String, class: AnyClass) {}
    open func registerCell(_ reuseIdentifier: String, nib: UINib) {}
    
    open func dequeu() -> Cell? { return nil }
    open func indexPath(_ cell: Cell) -> IndexPath? { return nil }
}
