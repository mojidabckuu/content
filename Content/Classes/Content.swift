//
//  Content.swift
//  Contents
//
//  Created by Vlad Gorbenko on 8/31/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

public enum State {
    case none
    case loading
    case refreshing
    case allLoaded
    case cancelled
}

public protocol ContentCell: _Cell, Raiser {}

open class Content<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: ActionRaiser where View: UIView {
    
    var adapter: Adapter<Model, View, Cell>
    public var items: Adapter<Model, View, Cell> {
        return self.adapter
    }
    public func set(_ items: [Model]) {
        self.adapter.items = items
        self.reloadData()
    }
    
    open var isEditing = false
    open var selectedItem: Model? {
        get { return self.delegate?.selectedItem }
        set { self.delegate?.selectedItem = newValue }
    }
    open var selectedItems: [Model]? {
        get { return self.delegate?.selectedItems }
        set { self.delegate?.selectedItems = newValue }
    }
    open var visibleItem: Model? {
        get { return self.delegate?.visibleItem }
        set { self.delegate?.visibleItem = newValue }
    }
    open var visibleItems: [Model]? {
        get { return self.delegate?.visibleItems }
        set { self.delegate?.visibleItems = newValue }
    }
    
    public private(set) var configuration: Configuration!
    
    open var view: View { return _view }
    private var _view: View
    open var delegate: BaseDelegate<Model, View, Cell>?
    
    let actions = ContentActionsCallbacks<Model, View, Cell>()
    let URLCallbacks = ContentURLCallbacks<Model, View, Cell>()
    var callbacks = ContentCallbacks<Model, View, Cell>()
    var scrollCallbacks = ScrollCallbacks<Model, View, Cell>()
    var viewDelegateCallbacks = ViewDelegateCallbacks<Model, View, Cell>()
    
    open var offset: Any?
    open var length: Int { return self.configuration.length }
    
    public init(view: View, delegate: BaseDelegate<Model, View, Cell>? = nil, configuration: Configuration? = nil) {
        self.adapter = AdapterGenerator.generate()
        self.configuration = configuration ?? Configuration.default()
        _view = view
        _view.contentDelegate = delegate
        _view.contentDataSource = delegate
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
            self.offset = nil
            configuration.infiniteControl?.isEnabled = true
            let isAnimating = configuration.refreshControl?.isAnimating
//            let refresh = configuration.refreshControl as? UIRefreshControl
            if isAnimating == false {
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
            configuration.refreshControl?.stopAnimating()
            configuration.infiniteControl?.stopAnimating()
            self.URLCallbacks.didLoad?(error, [])
            return
        }
        if let models = models {
            if self.state == .refreshing {
                self.adapter.removeAll()
                if self.configuration.animatedRefresh {
                    self.reloadData()
                    self.add(items: models, at: self.adapter.count)
                } else {
                    self.adapter.append(contentsOf: models)
                    self.reloadData()
                }
                configuration.refreshControl?.stopAnimating()
            } else {
                self.add(items: models, at: self.adapter.count)
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
    open func add(items models: [Model], at index: Int = 0) {
        self.delegate?.insert(models, index: index)
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
