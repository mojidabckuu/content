//
//  AnyContent.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 10/12/2017.
//

import Foundation

public protocol hasContent: class {
    var content: AnyContent { get }
}

public protocol AnyContent {
    
    var offset: Any? { get }
    var state: State { get }
    
    var configuration: Configuration { get }
    
    func reload()
    
    func update(_ block: () -> (), completion: (() -> ())?)
    func update(_ block: () -> ())
    
    func insert(_ newElement: Any, at index: Int, animated: Bool)
    func insert(contentsOf models: [Any], at index: Int, animated: Bool)
    
    func move(from: Int, to: Int)
    
    func delete(_ element: Any)
    func delete(contentsOf models: Any)
    
    func reload(_ element: Any, animated: Bool)
    func reload(contentsOf models: [Any], animated: Bool)
    
    func move(_ element: Any, to: Int)
    
    func view(for element: Any) -> UIView?
    
    func scrollTo(_ element: Any)
    func scrollToBegining()
    func scrollToEnd()
    
    func refresh()
    func loadMore()
}
