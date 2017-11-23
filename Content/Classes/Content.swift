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
    // Use it as temp access only. No items.count
    open var items: [Model] { return adapter.items }
    
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
    open var delegate: BaseDelegate<Model, View, Cell>? {
        didSet {
            delegate?.content = self
            _view.contentDelegate = delegate
            _view.contentDataSource = delegate
        }
    }
    
    let actions = ContentActionsCallbacks<Model, View, Cell>()
    let URLCallbacks = ContentURLCallbacks<Model, View, Cell>()
    var callbacks = ContentCallbacks<Model, View, Cell>()
    var scrollCallbacks = ScrollCallbacks<Model, View, Cell>()
    var viewDelegateCallbacks = ViewDelegateCallbacks<Model, View, Cell>()
    
    //TODO: Could be done better.
    open var offset: Any? {
        didSet {
            self.params["offset"] = self.offset
        }
    }
    open var params: [String : Any] = [:] {
        didSet {
            if let offset = self.offset {
                self.params["offset"] = offset
            }
        }
    }
    open var length: Int { return self.configuration.length }
    
    public init(view: View, delegate: BaseDelegate<Model, View, Cell>? = nil, configuration: Configuration? = nil, setup block: ((_ content: Content) -> Void)? = nil) {
        if let setupBlock = block {
            self.callbacks.onSetupBlock = setupBlock
        }
        self.adapter = AdapterGenerator.generate()
        self.configuration = configuration ?? Configuration.default()
        _view = view
        self.setup(delegate: delegate)
        self.setup(refreshControl: self.configuration?.refreshControl)
        self.setup(infiniteControl: self.configuration?.infiniteControl)
        
        self.callbacks.onSetupBlock?(self)
    }
    
    //MARK: - Setup
    func setup(delegate del: BaseDelegate<Model, View, Cell>?) {
        if let delegate = del {
            self.delegate = del
            return
        }
        // TODO: This code a bit redundant. Can solve by extracting to resolve manager.
        if delegate == nil {
            if view is UITableView {
                delegate = TableDelegate(content: self)
            } else if view is UICollectionView {
                delegate = CollectionFlowDelegate(content: self)
            }
        }
    }
    
    func setup(refreshControl: UIControl?) {
        if let refreshControl = refreshControl {
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
    }
    
    func setup(infiniteControl: UIControl?) {
        if let infiniteControl = infiniteControl {
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
            self.URLCallbacks.beforeRefresh?()
            _view.isScrollEnabled = true
            
            configuration.emptyView?.removeFromSuperview()
            configuration.errorView?.removeFromSuperview()
            
            _state = .refreshing
            self.offset = nil
            configuration.infiniteControl?.isEnabled = true
            let isAnimating = configuration.refreshControl?.isAnimating
            
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
    
    func handle(with error: Error) {
        let prevState = _state
        _state = .none
        configuration.refreshControl?.stopAnimating()
        configuration.refreshControl?.isEnabled = false
        _view.set(contentOffset: .zero)
        configuration.refreshControl?.isEnabled = true
        configuration.infiniteControl?.stopAnimating()
        configuration.emptyView?.removeFromSuperview()
        if prevState == .refreshing {
            self.adapter.removeAll()
            self.reloadData()
            self.adjustErrorView(error: error)
        }
        self.URLCallbacks.didLoad?(error, [])
    }
    
    func handle(refresh models: [Model], animated: Bool) {
        let recognizers = _view.gestureRecognizers
        if let recognizers = _view.gestureRecognizers {
            for recognizer in recognizers {
                _view.removeGestureRecognizer(recognizer)
            }
        }
        configuration.refreshControl?.stopAnimating()
        self.adapter.removeAll()
        self.reloadData()
        self.URLCallbacks.whenRefresh?()
        self.insert(contentsOf: models, at: 0, animated: animated)
        self.adjustEmptyView()
        if let recognizers = recognizers {
            for recognizer in recognizers {
                _view.addGestureRecognizer(recognizer)
            }
        }
        self.URLCallbacks.afterRefresh?()
    }
    
    func handle(more models: [Model], animated: Bool) {
        self.append(contentsOf: models, animated: animated)
    }
    
    func after(load models: [Model]) {
        //        self.URLCallbacks.didLoad?(error, models)
        self.adjustInfiniteView(length: models.count)
        configuration.infiniteControl?.stopAnimating()
    }
    
    open func fetch(error: Error) {
        handle(with: error)
    }
    
    @available(*, deprecated)
    open func fetch(_ models: [Model]?, error: Error?) {
        if let error = error {
            self.fetch(error: error)
        } else {
            self.fetch(models ?? [])
        }
    }
    
    open func fetch(_ models: [Model]) {
        //        guard let models = models else {
        //            configuration.refreshControl?.stopAnimating()
        //            configuration.infiniteControl?.stopAnimating()
        //            if let error  = error {
        //                handle(with: error)
        //            } else {
        //
        //            }
        //
        //            return
        //        }
        //        if let error = error {
        //            handle(with: error)
        //            return
        //        }
        switch _state {
        case .refreshing: handle(refresh: models, animated: configuration.animateRefresh)
        case .loading:    handle(more: models, animated: configuration.animateAppend)
        default: print("nothing")
        }
        after(load: models)
    }
    
    //MARK: - Management
    // Add
    //    open func add(items models: [Model], at index: Int = 0) {
    //        self.delegate?.insert(models, index: index, animated: true)
    //        self.adjustEmptyView()
    //
    //    }
    //    open func add(_ items: Model..., at index: Int = 0) {
    //        self.add(items: items, at: index)
    //    }
    
    open func insert(_ newElement: Model, at index: Int = 0, animated: Bool = true) {
        self.delegate?.insert([newElement], index: index, animated: animated)
        self.adjustEmptyView()
    }
    
    open func insert(_ models: [Model], at index: Int = 0) {
        self.insert(contentsOf: models, at: index, animated: true)
    }
    
    open func insert(contentsOf models: [Model], at index: Int = 0, animated: Bool = true) {
        self.delegate?.insert(models, index: index, animated: animated)
        self.adjustEmptyView()
    }
    
    open func append(contentsOf models: [Model], animated: Bool = true) {
        self.delegate?.insert(models, index: self.count, animated: animated)
    }
    
    open func append(_ models: Model..., animated: Bool = true) {
        self.delegate?.insert(models, index: self.count, animated: animated)
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
    
    open func reset(items: [Model] = [], showEmptyView: Bool = false, adjustInfinite: Bool = false) {
        self.adapter.items = items
        self.adjustEmptyView(hidden: !showEmptyView)
        if adjustInfinite {
            self.adjustInfiniteView(length: items.count)
        }
        self.reloadData()
    }
    
    // TODO: Think here how we can handle it consistent
    open func move(from: Int, to: Int) {
        let element = self.adapter.remove(at: from)
        self.adapter.insert(element, at: to)
    }
    
    private func adjustInfiniteView(length: Int) {
        if length < self.length || self.offset == nil {
            _state = .allLoaded
            configuration.infiniteControl?.isEnabled = false
        } else {
            _state = .none
        }
    }
    
    // TODO: Too complex
    private func adjustEmptyView(hidden: Bool = false) {
        if let emptyView = self.emptyView() {
            if let contentView = emptyView as? ContentView {
                contentView.setup(content: self)
            }
            if self.isEmpty && !hidden {
                configuration.refreshControl?.isEnabled = !self.isEmpty
                self.layout(view: emptyView)
                _view.set(contentOffset: .zero)
            } else {
                emptyView.removeFromSuperview()
                _view.isScrollEnabled = true
                configuration.refreshControl?.isEnabled = true
            }
        }
    }
    
    private func adjustErrorView(error: Error) {
        guard let errorView = self.errorView(error) else {
            if !_view.isScrollEnabled {
                _view.isScrollEnabled = true
            }
            return
        }
        if let contentView = errorView as? ContentView {
            contentView.setup(content: self)
        }
        if let errorHandleable = errorView as? ErrorHandleable {
            errorHandleable.setup(error: error)
        }
        layout(view: errorView)
        _view.set(contentOffset: .zero)
    }
    
    private func layout(view: UIView) {
        guard view.superview == nil else { return }
        _view.isScrollEnabled = false
        _view.addSubview(view)
        if #available(iOS 9.0, *) {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: _view.topAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: _view.leadingAnchor).isActive = true
            view.widthAnchor.constraint(equalTo: _view.widthAnchor).isActive = true
            view.heightAnchor.constraint(equalTo: _view.heightAnchor).isActive = true
        }
    }
    
    func emptyView() -> UIView? {
        let emptyView = configuration.currentEmptyView ?? self.URLCallbacks.emptyView?() ?? configuration.emptyView
        configuration.currentEmptyView = emptyView
        return emptyView
    }
    
    func errorView(_ error: Error) -> UIView? {
        let errorView = configuration.currentErrorView ?? self.URLCallbacks.errorView?(error) ?? configuration.errorView
        configuration.currentErrorView = errorView
        return errorView
    }
    
    //MARK: -
    open func register(cell: Cell.Type, nib: UINib) {
        self.delegate?.registerCell(cell.identifier, nib: nib)
    }
    
    open func register(cell: Cell.Type) {
        let nib = UINib(nibName: cell.identifier, bundle: Bundle.main)
        self.delegate?.registerCell(cell.identifier, nib: nib)
    }
    
    open func register(`class` cell: Cell.Type) {
        self.delegate?.registerCell(cell.identifier, cell: (cell as! AnyClass))
    }
}

extension Content: MutableCollection, BidirectionalCollection {
    //MARK: - MutableCollection & BidirectionalCollection impl
    open var startIndex: Int { return adapter.startIndex }
    open var endIndex: Int { return adapter.endIndex }
    
    open subscript (position: Int) -> Model {
        get { return adapter[position] }
        set { adapter[position] = newValue }
    }
    
    open subscript (range: Range<Int>) -> ArraySlice<Model> {
        get { return adapter[range] }
        set { adapter.replaceSubrange(range, with: newValue) }
    }
    
    open func index(after i: Int) -> Int { return adapter.index(after: i) }
    open func index(before i: Int) -> Int { return adapter.index(before: i) }
}

