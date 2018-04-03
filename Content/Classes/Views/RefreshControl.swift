//
//  RefreshControl.swift
//  Pods
//
//  Created by Vlad Gorbenko on 10/5/16.
//
//

import UIKit

extension UIControl: ContentControl {
    @objc open func startAnimating() {}
    @objc open func stopAnimating() {}
    
    @objc open var isAnimating: Bool { return false }
}

public extension UIRefreshControl {
    open override func startAnimating() {
        self.beginRefreshing()
    }
    
    open override func stopAnimating() {
        self.endRefreshing()
    }
    
    open override var isAnimating: Bool {
        return self.isRefreshing
    }
}

