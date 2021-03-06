//
//  Actions.swift
//  Pods
//
//  Created by Vlad Gorbenko on 10/6/16.
//
//

public protocol Action {}
extension String: Action {}

public func == (action: Action, key: String) -> Bool {
    guard let actionString = action as? String else { return false }
    return actionString == key
}

public func == (key: String, action: Action) -> Bool {
    guard let actionString = action as? String else { return false }
    return actionString == key
}

public protocol ActionRaiser: class {
//    var isEditing: Bool { get set }
    func raise(_ action: Action, sender: Raiser)
}

public protocol Raiser {
    var raiser: ActionRaiser? { get set }
}
