//
//  RefreshControl.swift
//  Pods
//
//  Created by Vlad Gorbenko on 10/5/16.
//
//

import UIKit

extension UIControl: ContentControl {
    public func startAnimating() {}
    public func stopAnimating() {}
    
    public var isAnimating: Bool { return false }
}

public extension UIRefreshControl {
    override func startAnimating() {
        self.beginRefreshing()
    }
    
    override func stopAnimating() {
        self.endRefreshing()
    }
    
    override var isAnimating: Bool {
        return self.isRefreshing
    }
}
