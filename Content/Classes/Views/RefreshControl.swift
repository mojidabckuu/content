//
//  RefreshControl.swift
//  Pods
//
//  Created by Vlad Gorbenko on 10/5/16.
//
//

import UIKit

extension UIRefreshControl: ContentView {
    func startAnimating() {
        self.beginRefreshing()
    }
    
    func stopAnimating() {
        self.endRefreshing()
    }
}
