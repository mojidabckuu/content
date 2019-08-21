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
    
    open override var selectedItem: Model? {
        set {
            self.select(model: newValue)
        }
        get {
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return nil }
            return self.content.items[indexPath.row]
        }
    }
    
    open override var selectedItems: [Model]? {
        set {
            self.select(models: newValue)
        }
        get {
            return self.tableView.indexPathsForSelectedRows?.map { self.content.items[$0.row] }
        }
    }
    
    open override var visibleItem: Model? {
        set {
            self.scroll(to: newValue)
        }
        get {
            guard let indexPath = self.tableView.indexPathsForVisibleRows?.first else { return nil }
            return self.content.items[indexPath.row]
        }
    }
    
    open override var visibleItems: [Model]? {
        set {
            self.scroll(to: newValue)
        }
        get {
            return self.tableView.indexPathsForVisibleRows?.map { self.content.items[$0.row] }
        }
    }
    
    public override init() {
        super.init()
    }
    override init(content: Content<Model, View, Cell>) {
        super.init(content: content)
    }
    
    // Select
    open override func select(model: Model?, animated: Bool = false, scrollPosition: ContentScrollPosition = .none) {
        guard let model = model else { return }
        if let index = self.content.items.index(of: model) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition.tableScroll)
        }
    }
    
    /** Scroll position will apply only for first item */
    open override func select(models: [Model]?, animated: Bool = false, scrollPosition: ContentScrollPosition = .none) {
        guard let models = models else { return }
        for (i, model) in models.enumerated() {
            self.select(model: model, animated: animated, scrollPosition: i == 0 ? scrollPosition : .none)
        }
    }
    
    open override func deselect(model: Model?, animated: Bool = false) {
        guard let model = model else { return }
        if let index = self.content.items.index(of: model) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.deselectRow(at: indexPath, animated: animated)
        }
    }
    
    open override func deselect(models: [Model]?, animated: Bool = false) {
        guard let models = models else { return }
        for (i, model) in models.enumerated() {
            self.deselect(model: model, animated: animated)
        }
    }
    
    //Scroll
    open override func scroll(to model: Model?, at: ContentScrollPosition = .middle, animated: Bool = true) {
        guard let model = model else { return }
        if let index = self.content.items.index(of: model) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: at.tableScroll, animated: animated)
        }
    }
    
    /** Scrolls to first item only */
    open override func scroll(to models: [Model]?, at: ContentScrollPosition = .top, animated: Bool = true) {
        guard let model = models?.first else { return }
        self.scroll(to: model, at: at, animated: animated)
    }
    
    // Insert
    override open func insert(_ models: [Model], index: Int = 0) {
        self.tableView.beginUpdates()
        self.content._items.insert(contentsOf: models, at: index)
        self.tableView.insertRows(at: self.indexPaths(models), with: .automatic)
        self.tableView.endUpdates()
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.content.isEditing
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let cell = tableView.cellForRow(at: indexPath) as? Cell, let callback = self.content.actions.onDelete {
            callback(self.content, self.content.items[indexPath.row], cell)
        }
    }
    
    //Delete
    open override func delete(_ models: [Model]) {
        self.tableView.beginUpdates()
        var indexes = models
            .flatMap { self.content.items.index(of: $0) }
            .map {IndexPath(row: $0, section: 0)}
        self.tableView.deleteRows(at: indexes, with: .fade)
        indexes.forEach { self.content._items.remove(at: $0.row) }
        self.tableView.endUpdates()
    }
    
    //Reload
    open override func reload(_ models: [Model], animated: Bool) {
        let indexes = self.indexPaths(models)
        let animationStyle: UITableViewRowAnimation = animated ? .automatic : .none
        self.tableView.reloadRows(at: indexes, with: animationStyle)
    }
    
    //Register
    override open func registerCell(_ reuseIdentifier: String, nib: UINib) {
        self.tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    //UITableView delegate
    
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = tableView.cellForRow(at: indexPath) as? Cell, let callback = self.content.actions.onShouldSelect, callback(self.content, self.content.items[indexPath.row], cell) == false {
            return nil
        }
        return indexPath
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? Cell, let callback = self.content.actions.onSelect {
            callback(self.content, self.content.items[indexPath.row], cell)
        }
        if self.content.configuration.autoDeselect {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? Cell, let callback = self.content.actions.onDeselect {
            callback(self.content, self.content.items[indexPath.row], cell)
        }
    }
    
    //UITableView data source
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.content.items.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.tableView(tableView, cellForRowAt: indexPath, with: Cell.identifier)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, with identifier: String) -> UITableViewCell {
        let item = self.content.items[indexPath.row]
        let id = self.content.callbacks.onDequeueBlock?(item)?.identifier ?? identifier
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        if var cell = tableViewCell as? Cell {
            cell.raiser = self.content
            self.content.callbacks.onCellSetupBlock?(item, cell)
        }
        return tableViewCell
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard var cell = cell as? Cell else { return }
        cell.raiser = self.content
        if let callback = self.content.callbacks.onCellDisplay {
            callback(self.content.items[indexPath.row], cell)
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let callback = self.content.callbacks.onHeight else { return tableView.rowHeight }
        return callback(self.content.items[indexPath.row]) ?? tableView.rowHeight
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let callback = self.content.callbacks.onHeight else { return tableView.estimatedRowHeight }
        return callback(self.content.items[indexPath.row]) ?? tableView.estimatedRowHeight
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.content.viewDelegateCallbacks.onHeaderDequeue?(self.content, section)
    }
    
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.content.viewDelegateCallbacks.onFooterDequeue?(self.content, section)
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.content.viewDelegateCallbacks.onHeaderViewDequeue?(self.content, section)
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.content.viewDelegateCallbacks.onFooterViewDequeue?(self.content, section)
    }
    
    //ScrollView
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.content.scrollCallbacks.onDidEndDecelerating?(self.content)
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.content.scrollCallbacks.onDidScroll?(self.content)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.content.scrollCallbacks.onDidEndDragging?(self.content, decelerate)
    }
    
    //Utils
    open override func indexPath(_ cell: Cell) -> IndexPath? {
        guard let cell = cell as? UITableViewCell else { return nil }
        return self.tableView.indexPath(for: cell)
    }
}
