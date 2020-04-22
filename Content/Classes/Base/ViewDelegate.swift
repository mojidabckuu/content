//
//  ViewDelegate.swift
//  Contents
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

public protocol Scrollable {}
extension Scrollable {
    var scrollView: UIScrollView { return self as! UIScrollView }
}

public protocol ViewDelegate: Scrollable {
    var contentDelegate: AnyObject? { get set }
    var contentDataSource: AnyObject? { get set }
 
    var isScrollEnabled: Bool { get set }
    
    // When try to confiorm contentOffset gives a crash on reload.
    func set(contentOffset: CGPoint)
    
    func reloadData()
}

public enum ContentScrollPosition {
    case none
    case top
    case middle
    case bottom
    
    case centeredVertically
    
    case left
    case centeredHorizontally
    case right
    
    public var tableScroll: UITableViewScrollPosition {
        switch self {
        case .top: return UITableViewScrollPosition.top
        case .middle, .centeredVertically: return UITableViewScrollPosition.middle
        case .bottom: return UITableViewScrollPosition.bottom
        default: return UITableViewScrollPosition.none
        }
    }
    
    public var collectionScroll: UICollectionViewScrollPosition {
        switch self {
        case .none: return []
        case .middle, .centeredVertically: return UICollectionViewScrollPosition.centeredVertically
        case .bottom: return UICollectionViewScrollPosition.bottom
        case .left: return UICollectionViewScrollPosition.left
        case .centeredHorizontally: return UICollectionViewScrollPosition.centeredHorizontally
        case .right: return UICollectionViewScrollPosition.right
        default: return UICollectionViewScrollPosition.top
        }
    }
}

open class BaseDelegate<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: NSObject where View: UIView {
    open weak var content: Content<Model, View, Cell>!
    open var selectedItem: Model?
    open var selectedItems: [Model]?
    open var visibleItem: Model?
    open var visibleItems: [Model]?
    
    public override init() {
        super.init()
    }
    
    init(content: Content<Model, View, Cell>) {
        self.content = content
        super.init()
    }
    
    // Setup
    open func setup() {}
    
    // Select
    open func select(model: Model?, animated: Bool, scrollPosition: ContentScrollPosition) {}
    open func select(models: [Model]?, animated: Bool, scrollPosition: ContentScrollPosition) {}
    open func deselect(model: Model?, animated: Bool) {}
    open func deselect(models: [Model]?, animated: Bool) {}
    
    //Scroll
    open func scroll(to model: Model?, at: ContentScrollPosition, animated: Bool) {}
    open func scroll(to models: [Model]?, at: ContentScrollPosition, animated: Bool) {}
    open func scrollToBottom() {}
    open func scrollToTop() {}
    
    public typealias Completion = (() -> ())
    
    //
    open func insert(_ models: [Model], index: Int, animated: Bool, completion: Completion? = nil) {}
    open func delete(_ models: [Model]) { }
    open func reload() {
        self.content.view.reloadData()
    }
    open func reload(_ models: [Model], animated: Bool) {}
    
    open func update(_ block: () -> (), completion: (() -> ())? = nil) {
        block()
    }
    
    open func move(from: Int, to: Int) {}
    
    open func indexPaths(_ models: [Model]) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for model in models {
            if let index = self.content.relation.index(of: model) {
                let indexPath = IndexPath(row: Int(index), section: 0)
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
    }
    
    //
    open func registerCell(_ reuseIdentifier: String, `class`: AnyClass) {
        self.registerCell(reuseIdentifier, cell: `class`)
    }
    open func registerCell(_ reuseIdentifier: String, cell: AnyClass?) {}
    open func registerCell(_ reuseIdentifier: String, nib: UINib) {}
    
    open func dequeu(at indexPath: IndexPath) -> Cell? { return nil }
    open func indexPath(_ cell: Cell) -> IndexPath? { return nil }
}

