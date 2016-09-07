//
//  TableViewDelegate.swift
//  Contents
//
//  Created by Vlad Gorbenko on 9/4/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

public class TableDelegate<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: BaseDelegate<Model, View, Cell>, UITableViewDelegate, UITableViewDataSource {

    public var tableView: UITableView { return self.content.view as! UITableView }
    override init(content: Content<Model, View, Cell>) {
        super.init(content: content)
    }
    
    // Insert
    
    override func insert(models: [Model], index: Int) {
        self.tableView.insertRowsAtIndexPaths(self.indexPaths(models), withRowAnimation: .Automatic)
    }
        
    override func indexPath(cell: Cell) -> NSIndexPath? {
        if let tableViewCell = cell as? UITableViewCell {
            return self.tableView.indexPathForCell(tableViewCell)
        }
        return nil
    }
    
    //Register
    
    override func registerCell(reuseIdentifier: String, nib: UINib) {
        self.tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    //UITableView delegate
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! Cell
        self.content.actions.onSelect?(self.content, self.content.items[indexPath.row], cell)
        if self.content.configuration.autoDeselect {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! Cell
        self.content.actions.onDeselect?(self.content, self.content.items[indexPath.row], cell)
    }
    
    //UITableView data source
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.content.items.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCellWithIdentifier(Cell.identifier, forIndexPath: indexPath)
        if var cell = tableViewCell as? Cell {
            cell.raiser = self.content
            self.content.callbacks.onCellSetupBlock?(self.content.items[indexPath.row], cell)
        }
        return tableViewCell
    }
}