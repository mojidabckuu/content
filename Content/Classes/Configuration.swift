//
//  Configuration.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

public typealias ContentConfiguration = Configuration

extension Configuration {
    @available(*, deprecated)
    public var animatedRefresh: Bool {
        get { return animateRefresh }
        set { animateRefresh = newValue }
    }
}

public struct Configuration {
    public var animateRefresh: Bool = false
    public var animateAppend: Bool = true
    public var length: Int = 20
    public var autoDeselect = true
    public var refreshControl: UIControl?
    public var infiniteControl: UIControl?
    
    public var size: CGSize?
    
    public var errorView: UIView? = DefaultErrorView()
    public var emptyView: UIView? = DefaultEmptyView()
    
    private static var _default: (() -> Configuration) = {
        return full()
    }
    public static var `default`: (() -> Configuration) {
        get { return { _default() } }
        set { _default = newValue }
    }
        
    // Default configuration is for normal flow with refresh/infinte controls.
    public static func full() -> Configuration {
        var configuration = self.default()
        configuration.refreshControl = UIRefreshControl()
        configuration.infiniteControl = UIInfiniteControl()
        return configuration
    }
    
    // Simple configuration to show list without refresh/infinite controls
    public static func regular() -> Configuration {
        var configuration = self.default()
        configuration.refreshControl = nil
        configuration.infiniteControl = nil
        return configuration
    }
    
    // Simple configuration to show refresh control only
    public static func refresh() -> Configuration {
        var configuration = Configuration.default()
        configuration.infiniteControl = nil
        return configuration
    }
    
    // Simple configuration to show infinite control only
    public static func infinite() -> Configuration {
        var configuration = Configuration.default()
        configuration.refreshControl = nil
        configuration.infiniteControl = configuration.infiniteControl ?? UIInfiniteControl()
        return configuration
    }
    
    public init(animatedRefresh: Bool = false, length: Int = 20, autoDeselect: Bool = true) {
        self.animatedRefresh = animatedRefresh
        self.length = length
        self.autoDeselect = autoDeselect
    }
}

