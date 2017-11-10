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
    
    open var count: Int { return adapter.count }
    open var isEmpty: Bool { return adapter.isEmpty }
    
    open func index(of model: Model) -> Int? {
        return adapter.index(of: model)
    }
    
    open var first: Model? { return adapter.first }
    open var last: Model? { return adapter.last }
    
    open subscript (position: Int) -> Model {
        get { return self.adapter[position] }
        set { self.replace(newValue, animated: true) }
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
        if let errorView = self.configuration.errorView as? ContentView {
            errorView.setup(content: self)
        }
        if let emptyView = self.configuration.emptyView {
            if let contentView = emptyView as? ContentView {
                contentView.setup(content: self)
            }
            emptyView.isHidden = true
            _view.addSubview(emptyView)
        }
    }
    
    deinit {
        print("Controller deinit")
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
            if #available(iOS 10.0, *) {
                if let scrollView = _view as? UIScrollView, let refreshControl = refreshControl as? UIRefreshControl {
                    scrollView.refreshControl = refreshControl
                } else {
                    self.view.addSubview(refreshControl)
                }
            } else {
                self.view.addSubview(refreshControl)
            }
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
    open var isLoading: Bool { return _state == .refreshing || _state == .loading }
    
    open func reloadData() {
        self.delegate?.reload()
    }
    
    open dynamic func refresh() {
        if _state != .refreshing {
            _view.isScrollEnabled = true
            configuration.emptyView?.isHidden = true
            configuration.errorView?.removeFromSuperview()
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
        let weakSelf = self
        self.URLCallbacks.onLoad?(weakSelf)
    }
    
    // Utils
    
    func handle(with error: Error) {
        let stateWas = _state
        _state = .none
        configuration.refreshControl?.stopAnimating()
        configuration.infiniteControl?.stopAnimating()
        configuration.emptyView?.isHidden = true
        if let errorView = configuration.errorView, stateWas == .refreshing {
            _view.isScrollEnabled = false
            errorView.frame = self.view.bounds
            errorView.layoutIfNeeded()
            self.view.addSubview(errorView)
        }
        self.URLCallbacks.didLoad?(error, [])
    }
    
    func handle(refresh models: [Model]) {
        let recognizers = _view.gestureRecognizers
        if let recognizers = _view.gestureRecognizers {
            for recognizer in recognizers {
                _view.removeGestureRecognizer(recognizer)
            }
        }
        configuration.refreshControl?.stopAnimating()
        self.adapter.removeAll()
        if self.configuration.animatedRefresh {
            self.reloadData()
            self.add(items: models, at: self.adapter.count)
        } else {
            self.adapter.append(contentsOf: models)
            self.reloadData()
        }
        self.adjustEmptyView()
        if let recognizers = recognizers {
            for recognizer in recognizers {
                _view.addGestureRecognizer(recognizer)
            }
        }
    }
    
    func handle(more models: [Model]) {
        self.add(items: models, at: self.adapter.count)
    }
    
    func after(load models: [Model], error: Error? = nil) {
        configuration.infiniteControl?.stopAnimating()
        self.URLCallbacks.didLoad?(error, models)
        if models.count < self.length {
            _state = .allLoaded
            configuration.infiniteControl?.isEnabled = false
        } else {
            _state = .none
        }
    }
    
    open func fetch(_ models: [Model]?, error: Error?) {
        guard let models = models else {
            configuration.refreshControl?.stopAnimating()
            configuration.infiniteControl?.stopAnimating()
            if let error  = error {
                handle(with: error)
            } else {
                
            }
            
            return
        }
        if let error = error {
            handle(with: error)
            return
        }
        switch _state {
        case .refreshing: handle(refresh: models)
        case .loading:    handle(more: models)
        default: print("nothing")
        }
        after(load: models, error: error)
    }
    
    //MARK: - Management
    // Add
    open func add(items models: [Model], at index: Int = 0) {
        self.delegate?.insert(models, index: index)
        self.adjustEmptyView()
        
    }
    open func add(_ items: Model..., at index: Int = 0) {
        self.add(items: items, at: index)
    }
    // Delete
    open func delete(items models: [Model]) {
        self.delegate?.delete(models)
        self.adjustEmptyView()
    }
    open func delete(_ models: Model...) {
        self.delegate?.delete(models)
        self.adjustEmptyView()
    }
    //Reload
    open func reload(_ models: Model..., animated: Bool = false) {
        self.delegate?.reload(models, animated: animated)
    }
    
    open func replace(_ models: Model..., animated: Bool = false) {
        fatalError("Not implemeted")
    }
    
    open func reset(items: [Model] = [], showEmptyView: Bool = false) {
        self.adapter.items = items
        self.adjustEmptyView(hidden: !showEmptyView)
        self.reloadData()
    }
    
    private func adjustEmptyView(hidden: Bool = false) {
        if let emptyView = configuration.emptyView {
            if self.isEmpty {
                configuration.refreshControl?.isEnabled = !self.isEmpty
                _view.set(contentOffset: .zero)
                emptyView.frame = _view.bounds
                emptyView.layoutIfNeeded()
                emptyView.isHidden = !self.isEmpty || hidden
            } else {
                let wasHidden = emptyView.isHidden
                emptyView.isHidden = !self.isEmpty || hidden
                if !wasHidden {
                    configuration.refreshControl?.isEnabled = true
                }
            }
            _view.isScrollEnabled = emptyView.isHidden
        }
    }
    
    //MARK: -
    open func register(cell: Cell.Type, nib: UINib) {
        self.delegate?.registerCell(cell.identifier, nib: nib)
    }
    
    open func register(cell: Cell.Type, identifier: String? = nil) {
        self.delegate?.registerCell(identifier ?? cell.identifier, cell: cell as? AnyClass)
    }
    
    //MARK: -
    open func map<T>(_ transform: (Model) -> T) -> [T] {
        return self.adapter.map(transform)
    }
}

