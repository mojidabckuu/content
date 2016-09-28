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
    case none
    case loading
    case refreshing
    case allLoaded
    case cancelled
}

class ContentActionsCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> {
    var onSelect: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    var onDeselect: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    var onAction: ((Content<Model, View, Cell>, Model, Cell, String) -> Void)?
    var onAdd: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    var onDelete: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
}

class ContentURLCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> {
    var onLoad: ((Content<Model, View, Cell>) -> Void)?
    var willLoad: (() -> Void)?
    var didLoad: ((NSError?, [Model]) -> Void)?
}

class ContentCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> {
    var onSetupBlock: ((Content<Model, View, Cell>) -> Void)?
    var onCellSetupBlock: ((Model, Cell) -> Void)?
    var onDequeue: ((Content<Model, View, Cell>, Model) -> Void)?
    var onLayout: ((Content<Model, View, Cell>, Model) -> CGSize)?
    var onItemChanged: ((Content<Model, View, Cell>, Model, Int) -> Void)?
}

class ScrollCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> {
    var onDidScroll: ((Content<Model, View, Cell>) -> Void)?
    var onDidEndDecelerating : ((Content<Model, View, Cell>) -> Void)?
    var onDidStartDecelerating : ((Content<Model, View, Cell>) -> Void)?
    var onDidEndDragging: ((Content<Model, View, Cell>, Bool) -> Void)?
}

public protocol ActionRaiser {
    func raise(_ action: String, sender: ContentCell)
}

//public extension ActionRaiser {
//    func raise(action: String) {}
//}

public protocol Raiser {
    var raiser: ActionRaiser? { get set }
}

public protocol ContentCell: _Cell, Raiser {}

open class Content<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: ActionRaiser {
    fileprivate var _items: [Model] = []
    open var items: [Model] {
        get { return _items }
        set {
            _items = newValue
            self.reloadData()
        }
    }
    let configuration = Configuration()
    open var model: Model?
    open var view: View { return _view }
    private var _view: View
    open var delegate: BaseDelegate<Model, View, Cell>?
    
    let actions = ContentActionsCallbacks<Model, View, Cell>()
    let URLCallbacks = ContentURLCallbacks<Model, View, Cell>()
    var callbacks = ContentCallbacks<Model, View, Cell>()
    var scrollCallbacks = ScrollCallbacks<Model, View, Cell>()
    
    var offset: Any?
    var length: Int { return self.configuration.length }
    
    public init(model: Model? = nil, view: View, delegate: BaseDelegate<Model, View, Cell>? = nil) {
        self.model = model
        _view = view
        
        _view.contentDelegate = delegate as? AnyObject
        _view.contentDataSource = delegate as? AnyObject
        if delegate == nil {
            if view is UITableView {
                self.delegate = TableDelegate<Model, View, Cell>(content: self)
                _view.contentDelegate = self.delegate
                _view.contentDataSource = self.delegate
            } else if view is UICollectionView {
                self.delegate = CollectionDelegate(content: self)
                _view.contentDelegate = self.delegate
                _view.contentDataSource = self.delegate
            }
        } else {
            self.delegate = delegate
        }
    }
    
    // URL lifecycle
    fileprivate var _state: State = .none
    open var state: State { return _state }
    open var isAllLoaded: Bool { return _state == .allLoaded }
    
    open func reloadData() {
        self.delegate?.reload()
    }
    open func refresh() {
        _state = .refreshing
        self.loadItems()
    }
    open func loadMore() {
        _state = .loading
        self.loadItems()
    }
    open func loadItems() {
        self.URLCallbacks.onLoad?(self)
    }
    
    // Utils
    
    open func fetch(_ models: [Model]?, error: NSError?) {
        if let error = error {
            _state = .none
            self.URLCallbacks.didLoad?(error, [])
            return
        }
        if let models = models {
            if self.state == .refreshing {
                _items.removeAll()
            }
            if self.configuration.animatedRefresh {
                self.add(models, index: _items.count)
                self.URLCallbacks.didLoad?(error, models)
            } else {
                _items.append(contentsOf: models)
                self.reloadData()
                self.URLCallbacks.didLoad?(error, models)
            }
            if models.count < self.length {
                _state = .allLoaded
            } else {
                _state = .none
            }
        }
    }
    
    // Management
    
    func add(_ items: [Model], index: Int = 0) {
        _items.insert(contentsOf: items, at: index)
        self.delegate?.insert(items, index: index)
    }
    func add(_ items: Model..., index: Int = 0) {
        self.add(items, index: index)
    }
    func delete(_ models: Model...) {
        self.delegate?.delete(models)
    }
    func reload(_ models: Model...) {
        self.delegate?.reload(models)
    }
}

// Setup
public extension Content {
    func on(cellSetup block: @escaping (_ model: Model, _ cell: Cell) -> Void) -> Content<Model, View, Cell> {
        self.callbacks.onCellSetupBlock = block
        return self
    }
    
    func on(setup block: @escaping (_ content: Content<Model, View, Cell>) -> Void) -> Content<Model, View, Cell> {
        self.callbacks.onSetupBlock = block
        block(self)
        return self
    }
}

// Actions
public extension Content {
    func on(select block: @escaping ((_ contnet: Content<Model, View, Cell>, _ model: Model, _ cell: Cell) -> Void)) -> Content<Model, View, Cell> {
        self.actions.onSelect = block
        return self
    }
    
    func on(deselect block: @escaping ((_ content: Content<Model, View, Cell>, _ model: Model, _ cell: Cell) -> Void)) -> Content<Model, View, Cell> {
        self.actions.onDeselect = block
        return self
    }
    
    func on(action block: @escaping ((_ content: Content<Model, View, Cell>, _ model: Model, _ cell: Cell, _ action: String) -> Void)) -> Content<Model, View, Cell> {
        self.actions.onAction = block
        return self
    }
}

// Loading
public extension Content {
    func on(load block: @escaping ((_ content: Content<Model, View, Cell>) -> Void)) -> Content<Model, View, Cell> {
        self.URLCallbacks.onLoad = block
        return self
    }
}

// Raising
public extension Content {
    func raise(_ action: String, sender: ContentCell) {
        if let cell = sender as? Cell, let indexPath = self.delegate?.indexPath(cell) {
            self.actions.onAction?(self, self._items[(indexPath as NSIndexPath).row], cell, action)
        }
    }
}

//CollectionView applicable
public extension Content where View: UICollectionView {
    func on(pageChange block: @escaping (Content<Model, View, Cell>, _ model: Model, _ page: Int) -> Void) -> Content {
        self.callbacks.onItemChanged = block
        return self
    }
    
    func on(layout block: @escaping ((_ content: Content<Model, View, Cell>, Model) -> CGSize)) -> Content<Model, View, Cell> {
        self.callbacks.onLayout = block
        return self
    }
}

public extension Content where View: UIScrollView {
    
    func on(didScroll block: ((Content<Model, View, Cell>) -> Void)?) -> Content {
        self.scrollCallbacks.onDidScroll = block
        return self
    }
    func on(didEndDecelerating block: ((Content<Model, View, Cell>) -> Void)?) -> Content {
        self.scrollCallbacks.onDidEndDecelerating = block
        return self
    }
    func on(didStartDecelerating block: ((Content<Model, View, Cell>) -> Void)?) -> Content {
        self.scrollCallbacks.onDidStartDecelerating = block
        return self
    }
    func on(didEndDragging block: ((Content<Model, View, Cell>, Bool) -> Void)?) -> Content {
        self.scrollCallbacks.onDidEndDragging = block
        return self
    }
    
}
