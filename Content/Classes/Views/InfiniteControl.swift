//
//  InfiniteControl.swift
//  Pods
//
//  Created by Vlad Gorbenko on 9/7/16.
//
//

import UIKit

public protocol ContentControl {
    func startAnimating()
    func stopAnimating()
    var isAnimating: Bool { get }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.origin.x + self.width / 2, y: self.origin.y + self.height / 2)
    }
}

open class UIInfiniteControl: UIControl {
    var height: CGFloat = 60
    var activityIndicatorView: UIActivityIndicatorView!
    
    override open var isAnimating: Bool { return self.activityIndicatorView.isAnimating }
    var isObserving: Bool { return _isObserving }
    var infiniteState: ControlState {
        set {
            if _state != newValue {
                let prevState = _state
                _state = newValue
                self.activityIndicatorView.center = self.bounds.center
                switch newValue {
                case .stopped:              self.activityIndicatorView.stopAnimating()
                case .triggered, .loading:  self.activityIndicatorView.startAnimating()
                default:                    self.activityIndicatorView.startAnimating()
                }
                if prevState == .triggered {
                    self.sendActions(for: .valueChanged)
                }
            }
        }
        get { return _state }
    }
    
    fileprivate var _state: ControlState = .stopped
    fileprivate var _isObserving = false
    
    fileprivate weak var scrollView: UIScrollView?
    fileprivate var originalInset: UIEdgeInsets = UIEdgeInsets()
    
    override open func startAnimating() {
        self.layoutSubviews()
        if self.isEnabled {
            self.infiniteState = .loading
        }
    }
    override open func stopAnimating() { self.infiniteState = .stopped }
    
    //MARK: - Lifecycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.stopObserveScrollView()
    }
    
    //MARK: - Setup
    func setup() {
        self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.activityIndicatorView.hidesWhenStopped = true
        self.addSubview(self.activityIndicatorView)
    }
    
    //MARK: - Layout
    override open func layoutSubviews() {
        super.layoutSubviews()
        if let size = self.scrollView?.bounds.size {
            self.frame = CGRect(x: 0, y: self.contentSize.height, width: size.width, height: self.height)
            self.activityIndicatorView.center = self.bounds.center
        }
    }
    
    //
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let scrollView = newSuperview as? UIScrollView {
            if self.scrollView == nil {
                self.scrollView = scrollView
                self.originalInset = scrollView.contentInset
            }
            self.startObserveScrollView()
        }
    }
    
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        if self.window == nil {
            self.stopObserveScrollView()
        } else {
            self.startObserveScrollView()
        }
    }
    
    // ScrollView
    
    func resetInsets() {
        if var contentInset = self.scrollView?.contentInset {
            contentInset.bottom = self.originalInset.bottom
            self.setContentInset(contentInset)
        }
    }
    
    func adjustInsets() {
        if let contentInset = self.scrollView?.contentInset {
            var newInsets = contentInset
            if self.isEnabled {
                newInsets.bottom = self.originalInset.bottom + self.height
            }
            if contentInset.bottom != newInsets.bottom {
                self.scrollView?.removeObserver(self, forKeyPath: "contentInset")
                self.setContentInset(newInsets)
                self.scrollView?.addObserver(self, forKeyPath: "contentInset", options: .new, context: nil)
            }
        }
    }
    
    func setContentInset(_ contentInset: UIEdgeInsets) {
        self.scrollView?.contentInset = contentInset
    }
    
    //MARK: - Observing
    func startObserveScrollView() {
        if !self.isObserving {
            self.scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            self.scrollView?.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
            self.scrollView?.addObserver(self, forKeyPath: "contentInset", options: .new, context: nil)
            _isObserving = true
            self.adjustInsets()
        }
    }
    func stopObserveScrollView() {
        if self.isObserving {
            self.scrollView?.removeObserver(self, forKeyPath: "contentOffset")
            self.scrollView?.removeObserver(self, forKeyPath: "contentSize")
            self.scrollView?.removeObserver(self, forKeyPath: "contentInset")
            _isObserving = false
            self.resetInsets()
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        if keyPath == "contentOffset" {
            if let offset = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgPointValue {
                self.scrollViewDidScroll(offset)
            }
        } else if keyPath == "contentSize" {
            self.layoutSubviews()
        } else if keyPath == "contentInset" {
            if let value = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                let targetBottom = self.isEnabled ? self.originalInset.bottom + self.height : self.originalInset.bottom
                if targetBottom != value.uiEdgeInsetsValue.bottom {
                    self.originalInset = value.uiEdgeInsetsValue
                    self.adjustInsets()
                }
            }
        }
    }
    
    // TableView returns wrong content size when takes table header and footer views.
    var contentSize: CGSize {
        if let tableView = self.scrollView as? UITableView {
            let rowsCount = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0) ?? 0
            if let footerView = tableView.tableFooterView , rowsCount == 0 {
                return CGSize(width: tableView.contentSize.width, height: footerView.frame.origin.y)
            }
            if let footerView = tableView.tableFooterView, let headerView = tableView.tableHeaderView, rowsCount == 0 {
                return CGSize(width: tableView.contentSize.width, height: footerView.bounds.height + headerView.bounds.height)
            }
            
        }
        if let collectionView = self.scrollView as? UICollectionView {
            if let sections = collectionView.dataSource?.numberOfSections!(in: collectionView) {
                let numberOfTotalRows = Array(0..<sections).map {
                 collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: $0) ?? 0
                }.reduce(0, +)
                // TODO: Very rude hack.
                if numberOfTotalRows == 0 && sections <= 1 {
                    return .zero
                }
            }
        }
        
        return self.scrollView?.contentSize ?? UIScreen.main.bounds.size
    }
    
    func scrollViewDidScroll(_ contentOffset: CGPoint) {
        if _state != .loading && self.isEnabled && contentOffset.y >= 0 {
            let contentSize = self.contentSize
            guard contentSize.height > CGFloat.leastNormalMagnitude else { return }
            let threshold = contentSize.height - self.scrollView!.bounds.size.height
            if _state == .triggered {
                self.infiniteState = .loading
            } else if contentOffset.y > threshold && _state == .stopped {
                self.infiniteState = .triggered
            } else if contentOffset.y < threshold && _state == .stopped {
                self.infiniteState = .stopped
            }
        }
    }
    
    // UIView
    override open var isEnabled: Bool {
        set {
            super.isEnabled = newValue
            if isEnabled {
                self.startObserveScrollView()
            } else {
                self.stopObserveScrollView()
            }
        }
        get { return super.isEnabled }
    }
    
    override open var tintColor: UIColor! {
        set {
            super.tintColor = newValue
            self.activityIndicatorView.color = newValue
        }
        get { return super.tintColor }
    }
}

extension UIInfiniteControl {
    enum ControlState {
        case stopped
        case triggered
        case loading
        case all
    }
}

