//
//  InfiniteControl.swift
//  Pods
//
//  Created by Vlad Gorbenko on 9/7/16.
//
//

import UIKit

class InfiniteControl: UIControl {
    var height: CGFloat = 60
    var activityIndicatorView: UIActivityIndicatorView!
    
    var isAnimating: Bool { return self.activityIndicatorView.isAnimating() }
    var isObserving: Bool { return _isObserving }
    var infiniteState: State {
        set {
            if _state != newValue {
                let prevState = _state
                _state = newValue
                self.activityIndicatorView.center = self.center
                switch newValue {
                case .Stopped:              self.activityIndicatorView.stopAnimating()
                case .Triggered, .Loading:  self.activityIndicatorView.startAnimating()
                default:                    self.activityIndicatorView.startAnimating()
                }
                if prevState == .Triggered {
                    self.sendActionsForControlEvents(.ValueChanged)
                }
            }
        }
        get { return _state }
    }
    
    private var _state: State = .Stopped
    private var _isObserving = false
    
    private weak var scrollView: UIScrollView?
    private var originalInset: UIEdgeInsets = UIEdgeInsets()
    
    func startAnimating() { self.infiniteState = .Loading }
    func stopAnimating() { self.infiniteState = .Stopped }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 
    
    func setup() {
        self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView.center = self.center
    }
    
    // Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.activityIndicatorView.center = self.center
    }
    
    //
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if let superView = self.superview, scrollView = newSuperview as? UIScrollView where self.scrollView == nil {
            self.scrollView = scrollView
            self.originalInset = scrollView.contentInset
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.window == nil {
            self.stopObserveScrollView()
        } else {
            self.startObserveScrollView()
        }
    }
    
    // ScrollView
    
    func resetInsets() {
        var contentInset = self.scrollView!.contentInset
        contentInset.bottom = self.originalInset.bottom
        self.setContentInset(contentInset)
    }
    
    func adjustInsets() {
        var contentInset = self.scrollView!.contentInset
        contentInset.bottom = self.originalInset.bottom + self.height
        self.setContentInset(contentInset)
    }
    
    func setContentInset(contentInset: UIEdgeInsets) {
        let options: UIViewAnimationOptions = [.AllowUserInteraction, .BeginFromCurrentState]
        UIView.animateWithDuration(0.3, delay: 0, options: options, animations: { [weak self] in
            self?.scrollView?.contentInset = contentInset
        }, completion: nil)
    }
    
    //
    
    func startObserveScrollView() {
        if self.isObserving {
            self.scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
            self.scrollView?.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil)
            _isObserving = true
            let size = self.scrollView!.bounds.size
            self.frame = CGRect(x: 0, y: self.contentSize.height, width: size.width, height: self.height)
        }
    }
    func stopObserveScrollView() {
        if self.isObserving {
            self.scrollView?.removeObserver(self, forKeyPath: "contentOffset")
            self.scrollView?.removeObserver(self, forKeyPath: "contentSize")
            _isObserving = false
            self.resetInsets()
        }
    }
    
    // TableView returns wrong content size when takes table header and footer views.
    var contentSize: CGSize {
        if let tableView = self.scrollView as? UITableView {
           let rowsCount = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0) ?? 0
            if let footerView = tableView.tableFooterView where rowsCount == 0 {
                return CGSize(width: tableView.contentSize.width, height: footerView.frame.origin.y)
            }
            if let footerView = tableView.tableFooterView, headerView = tableView.tableHeaderView rowsCount == 0 {
                return CGSize(width: tableView.contentSize.width, height: <#T##CGFloat#>)
            }
        
        }
        return self.scrollView?.contentSize ?? UIScreen.mainScreen().bounds.size
    }
    
    func scrollViewDidScroll(contentOffset: CGPoint) {
        if _state != .Loading && self.enabled {
            let contentSize = self.contentSize
            let threshold = contentSize.height - self.scrollView!.bounds.size.height
            if self.scrollView?.dragging == true && _state == .Triggered {
                self.infiniteState = .Loading
            } else if self.scrollView?.dragging == true && contentOffset.y > threshold && _state == .Stopped {
                self.infiniteState = .Triggered
            } else if contentOffset.y < threshold && _state == .Stopped {
                self.infiniteState = .Stopped
            }
        }
    }
    
    // UIView
    override var enabled: Bool {
        set {
            super.enabled = newValue
            if enabled {
                self.startObserveScrollView()
            } else {
                self.stopObserveScrollView()
            }
        }
        get { return super.enabled }
    }
    
    override var tintColor: UIColor! {
        set {
            super.tintColor = newValue
            self.activityIndicatorView.color = newValue
        }
        get { return super.tintColor }
    }
}

extension InfiniteControl {
    enum State {
        case Stopped
        case Triggered
        case Loading
        case All
    }
}
