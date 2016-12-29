//
//  InfiniteControl.swift
//  Pods
//
//  Created by Vlad Gorbenko on 9/7/16.
//
//

import UIKit

protocol ContentView {
    func startAnimating()
    func stopAnimating()
    var isAnimating: Bool { get }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.origin.x + self.width / 2, y: self.origin.y + self.height / 2)
    }
}

class UIInfiniteControl: UIControl {
    var height: CGFloat = 60
    var activityIndicatorView: UIActivityIndicatorView!
    
    override var isAnimating: Bool { return self.activityIndicatorView.isAnimating }
    var isObserving: Bool { return _isObserving }
    var infiniteState: State {
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
    
    fileprivate var _state: State = .stopped
    fileprivate var _isObserving = false
    
    fileprivate weak var scrollView: UIScrollView?
    fileprivate var originalInset: UIEdgeInsets = UIEdgeInsets()
    
    override func startAnimating() { self.infiniteState = .loading }
    override func stopAnimating() { self.infiniteState = .stopped }
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup
    func setup() {
        self.activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.activityIndicatorView.hidesWhenStopped = true
        self.addSubview(self.activityIndicatorView)
    }
    
    //MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = self.scrollView!.bounds.size
        self.frame = CGRect(x: 0, y: self.contentSize.height, width: size.width, height: self.height)
        self.activityIndicatorView.center = self.bounds.center
        self.bringSubview(toFront: self.activityIndicatorView)
    }
    
    //
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let scrollView = newSuperview as? UIScrollView {
            if self.scrollView == nil {
                self.scrollView = scrollView
                self.originalInset = scrollView.contentInset
            }
            self.startObserveScrollView()
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
        if self.isEnabled {
            contentInset.bottom = self.originalInset.bottom + self.height
        }
        self.setContentInset(contentInset)
    }
    
    func setContentInset(_ contentInset: UIEdgeInsets) {
        let options: UIViewAnimationOptions = [.allowUserInteraction, .beginFromCurrentState]
        UIView.animate(withDuration: 0.3, delay: 0, options: options, animations: { [weak self] in
            self?.scrollView?.contentInset = contentInset
        }, completion: nil)
    }
    
    //MARK: - Observing
    func startObserveScrollView() {
        if !self.isObserving {
            self.scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            self.scrollView?.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
            _isObserving = true
            self.adjustInsets()
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, keyPath == "contentOffset" {
            if let offset = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgPointValue { self.scrollViewDidScroll(offset) }
        } else {
            if let keyPath = keyPath, keyPath == "contentSize" { self.layoutSubviews() }
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
        return self.scrollView?.contentSize ?? UIScreen.main.bounds.size
    }
    
    func scrollViewDidScroll(_ contentOffset: CGPoint) {
        if _state != .loading && self.isEnabled {
            let contentSize = self.contentSize
            let threshold = contentSize.height - self.scrollView!.bounds.size.height
            if self.scrollView?.isDragging == true && _state == .triggered {
                self.infiniteState = .loading
            } else if self.scrollView?.isDragging == true && contentOffset.y > threshold && _state == .stopped {
                self.infiniteState = .triggered
            } else if contentOffset.y < threshold && _state == .stopped {
                self.infiniteState = .stopped
            }
        }
    }
    
    // UIView
    override var isEnabled: Bool {
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
    
    override var tintColor: UIColor! {
        set {
            super.tintColor = newValue
            self.activityIndicatorView.color = newValue
        }
        get { return super.tintColor }
    }
}

extension UIInfiniteControl {
    enum State {
        case stopped
        case triggered
        case loading
        case all
    }
}
