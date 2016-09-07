//
//  ViewDelegate.swift
//  Contents
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

public protocol ViewDelegate {
    var contentDelegate: AnyObject? { get set }
    var contentDataSource: AnyObject? { get set }
    
    func reloadData()
}

public class BaseDelegate<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: NSObject {
    public var content: Content<Model, View, Cell>
    
    public init(content: Content<Model, View, Cell>) {
        self.content = content
    }
    
    // Setup
    func setup() {}
    
    //
    func insert(models: [Model], index: Int = 0) {}
    func delete(models: [Model]) { }
    func reload() {
        self.content.view.reloadData()
    }
    func reload(models: [Model]) {}
    
    func indexPaths(models: [Model]) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        for model in models {
            if let index = self.content.items.indexOf(model) {
                let indexPath = NSIndexPath(forRow: Int(index), inSection: 0)
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
    }
    
    //
    func registerCell(reuseIdentifier: String, `class`: AnyClass) {}
    func registerCell(reuseIdentifier: String, nib: UINib) {}
    
    func dequeu() -> Cell? { return nil }
    func indexPath(cell: Cell) -> NSIndexPath? { return nil }
}