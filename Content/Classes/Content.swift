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
    case loaded
    case allLoaded
    case cancelled
    case error
}

public protocol ContentCell: _Cell, Raiser {}

open class Content<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: ActionRaiser where View: UIView {
    
//    internal var adapter: RelationAdapter<Model, View, Cell>
    // Use it as temp access only. No items.count
    open var relation: Relation<Model>
    open var items: [Model] { return relation.items }
    
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
    
    public private(set) var configuration: Configuration
    
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
    
    open var offset: Any? { return relation.offset }
    private var _params: [String : Any] = [:]
    open var params: [String : Any] {
        get {
            var params = _params
            if _state == .loading {
                params["offset"] = offset
            }
            return params
        }
        set { _params = newValue }
    }
    open var length: Int { return self.configuration.length }
    
    internal var currentErrorView: UIView?
    internal var currentEmptyView: UIView?
    
    public init(_ relation: Relation<Model>? = nil, view: View, delegate: BaseDelegate<Model, View, Cell>? = nil, configuration: Configuration? = nil, setup block: ((_ content: Content) -> Void)? = nil) {
        self.relation = relation ?? Relation()
        self.configuration = configuration ?? Configuration.default()
        _view = view
        
        self.setup(delegate: delegate)
        self.setup(refreshControl: self.configuration.refreshControl)
        self.setup(infiniteControl: self.configuration.infiniteControl)
        
        block?(self)
        
        if let relation = relation {
            reloadData()
            self.adjustInfinteControl()
            self.adjustEmptyView()
        }
    }
    
    //MARK: - Setup
    func setup(delegate del: BaseDelegate<Model, View, Cell>?) {
        if let delegate = del {
            self.delegate = delegate
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
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
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
            infiniteControl.addTarget(self, action: #selector(loadMore), for: .valueChanged)
            self.view.addSubview(infiniteControl)
        }
    }
    
    // URL lifecycle
    internal var _state: State = .none
    open var state: State { return _state }
    open var isAllLoaded: Bool { return _state == .allLoaded }
    open var isLoading: Bool { return _state == .refreshing || _state == .loading }
    
    @objc open func refresh() {
        if _state != .refreshing {
            self.URLCallbacks.beforeRefresh?()
            _view.isScrollEnabled = true
            
            self.currentEmptyView?.removeFromSuperview()
            self.currentErrorView?.removeFromSuperview()
            
            _state = .refreshing
            
            
            let isAnimating = configuration.refreshControl?.isAnimating
            
            if isAnimating == nil || isAnimating == false {
                self.configuration.infiniteControl?.startAnimating()
            }
            
            self.loadItems()
        }
    }
        
    @objc open dynamic func loadMore() {
        if _state != .loading && _state != .refreshing && _state != .allLoaded && self.offset != nil {
            _state = .loading
            configuration.infiniteControl?.startAnimating()
            self.loadItems()
        }
    }
    open func loadItems() {
        self.URLCallbacks.onLoad?(self)
    }
    
    // Utils
    
    func handle(with error: Error) {
        let prevState = _state
        _state = .error
        configuration.refreshControl?.stopAnimating()
        configuration.refreshControl?.isEnabled = false
        _view.set(contentOffset: .zero)
        configuration.refreshControl?.isEnabled = true
        configuration.infiniteControl?.stopAnimating()
        self.currentEmptyView?.removeFromSuperview()
        self.currentErrorView?.removeFromSuperview()
        self.currentErrorView = nil
        if prevState == .refreshing {
            self.relation.removeAll()
            self.reloadData()
            self.adjustErrorView(error: error)
        }
        // TODO: Did load with an error callback
    }
    
    func handle(refresh models: [Model], animated: Bool, completion: @escaping () ->()) {
        let recognizers = _view.gestureRecognizers
        if let recognizers = _view.gestureRecognizers {
            for recognizer in recognizers {
                _view.removeGestureRecognizer(recognizer)
            }
        }
        configuration.refreshControl?.stopAnimating()
        self.relation.removeAll()
        self.reloadData()
        self.URLCallbacks.whenRefresh?()
        self.insert(contentsOf: models, at: 0, animated: animated, completion: completion)
        if self.isEmpty {
            self.currentEmptyView?.removeFromSuperview()
            self.currentErrorView?.removeFromSuperview()
            self.adjustEmptyView()
        }
        if let recognizers = recognizers {
            for recognizer in recognizers {
                _view.addGestureRecognizer(recognizer)
            }
        }
        self.URLCallbacks.afterRefresh?()
    }
    
    func handle(more models: [Model], animated: Bool, completion: @escaping () ->()) {
        self.append(contentsOf: models, animated: animated, completion: completion)
    }
    
    func after(load models: [Model]) {
        if length < self.length || self.offset == nil {
            _state = .allLoaded
        } else {
            _state = .loaded
        }
        configuration.infiniteControl?.stopAnimating()
    }
    
    open func fetch(error: Error) {
        handle(with: error)
    }
    
    open func fetch(relation: Relation<Model>) {
//        self.relation.append(relation: relation)
        self.relation.offset = relation.offset
//        self.offset = relation.offset
        self.fetch(relation.items)
    }
    
    open func fetch(_ models: [Model]) {
        let completion: () -> () = {
            self.after(load: models)
            self.URLCallbacks.didLoad?(self, models)
        }
        self.adjustInfiniteView(length: models.count)
        switch _state {
        case .refreshing: handle(refresh: models, animated: configuration.animateRefresh, completion: completion)
        case .loading:    handle(more: models, animated: configuration.animateAppend, completion: completion)
        default: print("nothing")
        }
    }
    
    internal func adjustInfinteControl() {
        if self.relation.hasMore {
            configuration.infiniteControl?.isEnabled = true
            _state = .loaded
        } else {
            _state = .allLoaded
            configuration.infiniteControl?.isEnabled = false
        }
    }
    
    internal func adjustInfiniteView(length: Int) {
        if length < self.length || self.offset == nil {
            configuration.infiniteControl?.isEnabled = false
        } else {
            configuration.infiniteControl?.isEnabled = true
        }
    }
    
    // TODO: Too complex
    internal func adjustEmptyView(hidden: Bool = false) {
        guard let emptyView = self.emptyView() else { return }
        
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
    
    internal func adjustErrorView() {
        if let errorView = self.currentErrorView {
            if !_view.isScrollEnabled {
                _view.isScrollEnabled = true
            }
            errorView.removeFromSuperview()
        }
    }
    
    internal func adjustErrorView(error: Error) {
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
            _view.layoutMargins = .zero
            view.topAnchor.constraint(equalTo: _view.layoutMarginsGuide.topAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: _view.layoutMarginsGuide.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: _view.layoutMarginsGuide.trailingAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: _view.layoutMarginsGuide.bottomAnchor).isActive = true
        }
    }
    
    private func emptyView() -> UIView? {
        let emptyView = self.currentEmptyView ?? self.URLCallbacks.emptyView?() ?? configuration.emptyView
        self.currentEmptyView = emptyView
        return emptyView
    }
    
    private func errorView(_ error: Error) -> UIView? {
        let errorView = self.currentErrorView ?? self.URLCallbacks.errorView?(error) ?? configuration.errorView
        self.currentErrorView = errorView
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

//MARK: - Deprecated
extension Content {
    @available(*, deprecated)
    open func reloadData() {
        self.delegate?.reload()
    }
    
    @available(*, deprecated)
    open func fetch(_ models: [Model]?, error: Error?) {
        if let error = error {
            self.fetch(error: error)
        } else {
            self.fetch(models ?? [])
        }
    }
}
