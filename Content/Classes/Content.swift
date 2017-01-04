//
//  Content.swift
//  Contents
//
//  Created by Vlad Gorbenko on 8/31/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

public struct Configuration {
    public var animatedRefresh: Bool = false
    public var length: Int = 20
    public var autoDeselect = true
    public var refreshControl: UIControl?
    public var infiniteControl: UIControl?
    
    // Default configuration is for normal flow with refresh/infinte controls.
    public static var `default`: Configuration {
        var configuration = Configuration()
        configuration.refreshControl = UIRefreshControl()
        configuration.infiniteControl = UIInfiniteControl()
        return configuration
    }
    
    // Simple configuration to show list without refresh/infinite controls
    public static var regular: Configuration {
        var configuration = Configuration()
        return configuration
    }
    
    // Simple configuration to show list without refresh/infinite controls
    public static var infinite: Configuration {
        var configuration = Configuration()
        configuration.infiniteControl = UIInfiniteControl()
        return configuration
    }
}

public enum State {
    case none
    case loading
    case refreshing
    case allLoaded
    case cancelled
}

class ContentActionsCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    var onSelect: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    var onDeselect: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    var onAction: ((Content<Model, View, Cell>, Model, Cell, Action) -> Void)?
    var onAdd: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    var onDelete: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
}

class ContentURLCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    var onLoad: ((Content<Model, View, Cell>) -> Void)?
    var willLoad: (() -> Void)?
    var didLoad: ((Error?, [Model]) -> Void)?
}

class ContentCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    var onSetupBlock: ((Content<Model, View, Cell>) -> Void)?
    var onCellSetupBlock: ((Model, Cell) -> Void)?
    var onLayout: ((Content<Model, View, Cell>, Model) -> CGSize)?
    var onItemChanged: ((Content<Model, View, Cell>, Model, Int) -> Void)?
}

class ScrollCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    var onDidScroll: ((Content<Model, View, Cell>) -> Void)?
    var onDidEndDecelerating : ((Content<Model, View, Cell>) -> Void)?
    var onDidStartDecelerating : ((Content<Model, View, Cell>) -> Void)?
    var onDidEndDragging: ((Content<Model, View, Cell>, Bool) -> Void)?
}

class ViewDelegateCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    var onHeaderViewDequeue: ((Content<Model, View, Cell>, Int) -> UIView?)?
    var onHeaderDequeue: ((Content<Model, View, Cell>, Int) -> String?)?
    var onFooterViewDequeue: ((Content<Model, View, Cell>, Int) -> UIView?)?
    var onFooterDequeue: ((Content<Model, View, Cell>, Int) -> String?)?
}

public protocol ContentCell: _Cell, Raiser {}

open class Content<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: ActionRaiser where View: UIView {
    private var _items: [Model] = []
    open var isEditing = false
    open var items: [Model] {
        get { return _items }
        set {
            _items = newValue
            self.reloadData()
        }
    }
    var configuration = Configuration.default
    open var model: Model?
    open var view: View { return _view }
    private var _view: View
    open var delegate: BaseDelegate<Model, View, Cell>?
    
    let actions = ContentActionsCallbacks<Model, View, Cell>()
    let URLCallbacks = ContentURLCallbacks<Model, View, Cell>()
    var callbacks = ContentCallbacks<Model, View, Cell>()
    var scrollCallbacks = ScrollCallbacks<Model, View, Cell>()
    var viewDelegateCallbacks = ViewDelegateCallbacks<Model, View, Cell>()
    
    var offset: Any?
    var length: Int { return self.configuration.length }
    
    public init(model: Model? = nil, view: View, delegate: BaseDelegate<Model, View, Cell>? = nil, configuration: Configuration? = nil) {
        self.model = model
        if let configuration = configuration {
            self.configuration = configuration
        }
        _view = view
        _view.contentDelegate = delegate as? AnyObject
        _view.contentDataSource = delegate as? AnyObject
        self.delegate = delegate
        self.setupDelegate()
        self.setupControls()
    }
    
    func setupDelegate() {
        if self.delegate == nil {
            if view is UITableView {
                self.delegate = TableDelegate(content: self)
                _view.contentDelegate = self.delegate
                _view.contentDataSource = self.delegate
            } else if view is UICollectionView {
                self.delegate = CollectionDelegate(content: self)
                _view.contentDelegate = self.delegate
                _view.contentDataSource = self.delegate
            }
        } else {
            self.delegate?.content = self
        }
    }
    
    func setupControls() {
        if let refreshControl = self.configuration.refreshControl {
            refreshControl.addTarget(self, action: "refresh", for: .valueChanged)
            self.view.addSubview(refreshControl)
        }
        if let infiniteControl = self.configuration.infiniteControl {
            infiniteControl.addTarget(self, action: "loadMore", for: .valueChanged)
            self.view.addSubview(infiniteControl)
        }
    }
    
    // URL lifecycle
    fileprivate var _state: State = .none
    open var state: State { return _state }
    open var isAllLoaded: Bool { return _state == .allLoaded }
    
    open func reloadData() {
        self.delegate?.reload()
    }
    open dynamic func refresh() {
        if _state != .refreshing {
            _state = .refreshing
            configuration.infiniteControl?.isEnabled = true
            let isAnimating = configuration.refreshControl?.isAnimating
            let refresh = configuration.refreshControl as? UIRefreshControl
            let isA = refresh?.isAnimating
            if !(configuration.refreshControl?.isAnimating == true) {
                self.configuration.infiniteControl?.startAnimating()
            }
            self.loadItems()
        }
    }
    open dynamic func loadMore() {
        if _state != .loading && _state != .refreshing && _state != .allLoaded {
            _state = .loading
            self.loadItems()
        }
    }
    open func loadItems() {
        self.URLCallbacks.onLoad?(self)
    }
    
    // Utils
    
    open func fetch(_ models: [Model]?, error: Error?) {
        if let error = error {
            _state = .none
            self.URLCallbacks.didLoad?(error, [])
            return
        }
        if let models = models {
            if self.state == .refreshing {
                _items.removeAll()
                if self.configuration.animatedRefresh {
                    self.reloadData()
                    self.add(items: models, at: _items.count)
                } else {
                    _items.append(contentsOf: models)
                    self.reloadData()
                }
                configuration.refreshControl?.stopAnimating()
            } else {
                self.add(items: models, at: _items.count)
            }
            configuration.infiniteControl?.stopAnimating()
            self.URLCallbacks.didLoad?(error, models)
            if models.count < self.length {
                _state = .allLoaded
                configuration.infiniteControl?.isEnabled = false
            } else {
                _state = .none
            }
        }
    }
    
    //MARK: - Management
    // Add
    open func add(items items: [Model], at index: Int = 0) {
        self.delegate?.insert(items, index: index)
    }
    open func add(_ items: Model..., at index: Int = 0) {
        self.add(items: items, at: index)
    }
    // Delete
    open func delete(items models: [Model]) {
        self.delegate?.delete(models)
    }
    open func delete(_ models: Model...) {
        self.delegate?.delete(models)
    }
    //Reload
    open func reload(_ models: Model..., animated: Bool = false) {
        self.delegate?.reload(models, animated: animated)
    }
}

