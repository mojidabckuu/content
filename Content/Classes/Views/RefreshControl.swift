//
//  RefreshControl.swift
//  Pods
//
//  Created by Vlad Gorbenko on 10/5/16.
//
//

import UIKit

open class RefreshControl: UIRefreshControl, ContentView {
    open func startAnimating() {
        self.beginRefreshing()
    }
    
    open func stopAnimating() {
        self.endRefreshing()
    }
    
    open var isAnimating: Bool {
        return self.isRefreshing
    }
}
