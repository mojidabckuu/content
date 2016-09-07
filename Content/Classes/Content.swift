//
//  Content.swift
//  Contents
//
//  Created by Vlad Gorbenko on 8/31/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

public struct Configuration {
    var refreshControl: Bool = true
    var infiniteScrolling: Bool = true
    var animatedRefresh: Bool = true
    var length: Int = 20
    var autoDeselect = true
}

public enum State {
    case None
    case Loading
    case Refreshing
    case AllLoaded
    case Cancelled
}

class ContentActionsCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> {
    var onSelect: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    var onDeselect: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    var onAction: ((Content<Model, View, Cell>, Model, Cell, String) -> Void)?
    var onAdd: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    var onDelete: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
}

class ContentURLCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> {
    var onLoad: (Content<Model, View, Cell> -> Void)?
    var willLoad: (() -> Void)?
    var didLoad: ((NSError?, [Model]) -> Void)?
}

class ContentCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> {
    var onSetupBlock: ((Content<Model, View, Cell>) -> Void)?
    var onCellSetupBlock: ((Model, Cell) -> Void)?
    var onDequeue: ((Content<Model, View, Cell>, Model) -> Void)?
    var onLayout: ((Content<Model, View, Cell>, Model) -> CGSize)?
}

public protocol ActionRaiser {
    func raise(action: String, sender: ContentCell)
}

//public extension ActionRaiser {
//    func raise(action: String) {}
//}

public protocol Raiser {
    var raiser: ActionRaiser? { get set }
}

public protocol ContentCell: _Cell, Raiser {}

public class Content<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: ActionRaiser {
    private var _items: [Model] = []
    public var items: [Model] {
        get { return _items }
        set {
            _items = newValue
            self.reloadData()
        }
    }
    let configuration = Configuration()
    public var model: Model?
    public let view: View!
    public var delegate: BaseDelegate<Model, View, Cell>?
    
    let actions = ContentActionsCallbacks<Model, View, Cell>()
    let URLCallbacks = ContentURLCallbacks<Model, View, Cell>()
    var callbacks = ContentCallbacks<Model, View, Cell>()
    
    var offset: Any?
    var length: Int { return self.configuration.length }
    
    public init(model: Model? = nil, view: View, delegate: BaseDelegate<Model, View, Cell>? = nil) {
        self.model = model
        self.view = view
        
        self.view.contentDelegate = delegate as? AnyObject
        self.view.contentDataSource = delegate as? AnyObject
        if delegate == nil {
            if view is UITableView {
                self.delegate = TableDelegate<Model, View, Cell>(content: self)
                self.view.contentDelegate = self.delegate
                self.view.contentDataSource = self.delegate
            } else if view is UICollectionView {
                self.delegate = CollectionDelegate(content: self)
                self.view.contentDelegate = self.delegate
                self.view.contentDataSource = self.delegate
            }
        } else {
            self.delegate = delegate
        }
    }
    
    // URL lifecycle
    private var _state: State = .None
    public var state: State { return _state }
    public var isAllLoaded: Bool { return _state == .AllLoaded }
    
    public func reloadData() {
        self.delegate?.reload()
    }
    public func refresh() {
        _state = .Refreshing
        self.loadItems()
    }
    public func loadMore() {
        _state = .Loading
        self.loadItems()
    }
    public func loadItems() {
        self.URLCallbacks.onLoad?(self)
    }
    
    // Utils
    
    public func fetch(models: [Model]?, error: NSError?) {
        if let error = error {
            _state = .None
            self.URLCallbacks.didLoad?(error, [])
            return
        }
        if let models = models {
            if self.state == .Refreshing {
                _items.removeAll()
            }
            if self.configuration.animatedRefresh {
                self.add(models, index: _items.count)
                self.URLCallbacks.didLoad?(error, models)
            } else {
                _items.appendContentsOf(models)
                self.reloadData()
                self.URLCallbacks.didLoad?(error, models)
            }
            if models.count < self.length {
                _state = .AllLoaded
            } else {
                _state = .None
            }
        }
    }
    
    // Management
    
    func add(items: [Model], index: Int = 0) {
        _items.insertContentsOf(items, at: index)
        self.delegate?.insert(items, index: index)
    }
    func add1(models: Model..., index: Int = 0) {
        self.add(models, index: index)
    }
    
    func delete(models: Model...) {
        self.delegate?.delete(models)
    }
    func reload(models: Model...) {
        self.delegate?.reload(models)
    }
}

// Setup
public extension Content {
    func onCellSetup(block: (model: Model, cell: Cell) -> Void) -> Content<Model, View, Cell> {
        self.callbacks.onCellSetupBlock = block
        return self
    }
    
    func onSetup(block: (content: Content<Model, View, Cell>) -> Void) -> Content<Model, View, Cell> {
        self.callbacks.onSetupBlock = block
        block(content: self)
        return self
    }
}

// Actions
public extension Content {
    func onSelect(block: ((contnet: Content<Model, View, Cell>, model: Model, cell: Cell) -> Void)) -> Content<Model, View, Cell> {
        self.actions.onSelect = block
        return self
    }
    
    func onDeselect(block: ((content: Content<Model, View, Cell>, model: Model, cell: Cell) -> Void)) -> Content<Model, View, Cell> {
        self.actions.onDeselect = block
        return self
    }
    
    func onAction(block: ((content: Content<Model, View, Cell>, model: Model, cell: Cell, action: String) -> Void)) -> Content<Model, View, Cell> {
        self.actions.onAction = block
        return self
    }
}

// Loading
public extension Content {
    func onLoad(block: ((content: Content<Model, View, Cell>) -> Void)) -> Content<Model, View, Cell> {
        self.URLCallbacks.onLoad = block
        return self
    }
}

public extension Content where View: UICollectionView {
    func onLayout(block: ((content: Content<Model, View, Cell>, model: Model) -> CGSize)) -> Content<Model, View, Cell> {
        self.callbacks.onLayout = block
        return self
    }
}

// Raising
public extension Content {
    func raise(action: String, sender: ContentCell) {
        if let cell = sender as? Cell, let indexPath = self.delegate?.indexPath(cell) {
            self.actions.onAction?(self, self._items[indexPath.row], cell, action)
        }
    }
}