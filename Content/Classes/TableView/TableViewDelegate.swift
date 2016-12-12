//
//  TableViewDelegate.swift
//  Contents
//
//  Created by Vlad Gorbenko on 9/4/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

extension UITableView: Scrollable {}

open class TableDelegate<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: BaseDelegate<Model, View, Cell>, UITableViewDelegate, UITableViewDataSource where View: UIView {

    open var tableView: UITableView { return self.content.view as! UITableView }
    public override init() {
        super.init()
    }
    override init(content: Content<Model, View, Cell>) {
        super.init(content: content)
    }
    
    // Insert
    
    override open func insert(_ models: [Model], index: Int) {
        self.tableView.insertRows(at: self.indexPaths(models), with: .automatic)
    }
        
    override open func indexPath(_ cell: Cell) -> IndexPath? {
        if let tableViewCell = cell as? UITableViewCell {
            return self.tableView.indexPath(for: tableViewCell)
        }
        return nil
    }
    
    //Register
    
    override open func registerCell(_ reuseIdentifier: String, nib: UINib) {
        self.tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    //UITableView delegate
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! Cell
        self.content.actions.onSelect?(self.content, self.content.items[(indexPath as NSIndexPath).row], cell)
        if self.content.configuration.autoDeselect {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! Cell
        self.content.actions.onDeselect?(self.content, self.content.items[(indexPath as NSIndexPath).row], cell)
    }
    
    //UITableView data source
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.content.items.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath)
        if var cell = tableViewCell as? Cell {
            cell.raiser = self.content
            self.content.callbacks.onCellSetupBlock?(self.content.items[(indexPath as NSIndexPath).row], cell)
        }
        return tableViewCell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.content.viewDelegateCallbacks.onHeaderDequeue?(self.content, section)
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.content.viewDelegateCallbacks.onFooterDequeue?(self.content, section)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.content.viewDelegateCallbacks.onHeaderViewDequeue?(self.content, section)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.content.viewDelegateCallbacks.onFooterViewDequeue?(self.content, section)
    }
    
    //ScrollView
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.content.scrollCallbacks.onDidEndDecelerating?(self.content)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.content.scrollCallbacks.onDidScroll?(self.content)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.content.scrollCallbacks.onDidEndDragging?(self.content, decelerate)
    }
}
