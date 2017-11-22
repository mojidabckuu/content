//
//  RefreshControl.swift
//  Pods
//
//  Created by Vlad Gorbenko on 10/5/16.
//
//

import UIKit

extension UIControl: ContentControl {
    open func startAnimating() {}
    open func stopAnimating() {}
    
    open var isAnimating: Bool { return false }
}

public extension UIRefreshControl {
    override open func startAnimating() {
        self.beginRefreshing()
    }
    
    override open func stopAnimating() {
        self.endRefreshing()
    }
    
    override open var isAnimating: Bool {
        return self.isRefreshing
    }
}

