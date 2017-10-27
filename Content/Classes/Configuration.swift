//
//  Configuration.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

public struct Configuration {
    public var animatedRefresh: Bool = false
    public var length: Int = 20
    public var isOffsetFirst = true
    public var autoDeselect = true
    public var refreshControl: UIControl?
    public var infiniteControl: UIControl?
    
    public var errorView: UIView? = ErrorView()
    public var emptyView: UIView? = EmptyView()
    
    public static var `default`: (() -> Configuration) = {
        return items()
    }
    
    public static var adapterGenerator = AdapterGenerator.init()
    
    // Default configuration is for normal flow with refresh/infinte controls.
    public static func items() -> Configuration {
        var configuration = Configuration()
        configuration.refreshControl = UIRefreshControl()
        configuration.infiniteControl = UIInfiniteControl()
        return configuration
    }
    
    public static func relation() -> Configuration {
        var configuration = Configuration()
        configuration.refreshControl = UIRefreshControl()
        configuration.infiniteControl = UIInfiniteControl()
        //        configuration.adapterGenerator = RelationAdapter.init()
        return configuration
    }
    
    // Simple configuration to show list without refresh/infinite controls
    public static func regular() -> Configuration {
        return Configuration()
    }
    
    // Simple configuration to show list without refresh/infinite controls
    public static func infinite() -> Configuration {
        var configuration = Configuration()
        configuration.infiniteControl = UIInfiniteControl()
        return configuration
    }
    
    public init(animatedRefresh: Bool = false, length: Int = 50, autoDeselect: Bool = true) {
        self.animatedRefresh = animatedRefresh
        self.length = length
        self.autoDeselect = autoDeselect
    }
}
