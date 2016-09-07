//
//  Cell.swift
//  Contents
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

public protocol _CellType {}
public extension _CellType {
    static var identifier: String { return "\(self)" }
    static var nib: UINib { return UINib(nibName: self.identifier, bundle: nil) }
}

public protocol _Cell: _CellType {
//    var content: Content<A
}