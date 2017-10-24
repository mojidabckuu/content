//
//  RefreshControl.swift
//  Pods
//
//  Created by Vlad Gorbenko on 10/5/16.
//
//

import UIKit

extension UIControl: ContentView {
    func startAnimating() {}
    func stopAnimating() {}
    
    var isAnimating: Bool { return false }
}

extension UIRefreshControl {
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
