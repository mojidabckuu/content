//
//  Extensions.swift
//  Contents
//
//  Created by Vlad Gorbenko on 9/4/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit
import ObjectiveC

extension UITableView: ViewDelegate {}
public extension UITableView {
    var contentDelegate: AnyObject? {
        get { return self.delegate }
        set { self.delegate = newValue as? UITableViewDelegate }
    }
    var contentDataSource: AnyObject? {
        get { return self.dataSource }
        set { self.dataSource = newValue as? UITableViewDataSource }
    }
}

extension UITableViewCell: _Cell {}