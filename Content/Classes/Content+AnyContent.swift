//
//  Content+AnyContent.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 10/12/2017.
//

import Foundation

extension Content: AnyContent {
    
    public func insert(_ newElement: Any, at index: Int, animated: Bool) {
        guard let realElement = newElement as? Model else { return }
        self.insert(realElement, at: index, animated: animated)
    }
    
    public func insert(contentsOf models: [Any], at index: Int, animated: Bool) {
        guard let realElements = models as? [Model] else { return }
        self.insert(contentsOf: realElements, at: index, animated: animated)
    }
    
    public func delete(_ element: Any) {
        guard let realElement = element as? Model else { return }
        self.delete(realElement)
    }
    
    public func delete(contentsOf models: Any) {
        guard let realElements = models as? [Model] else { return }
        self.delete(realElements)
    }
    
    public func move(_ element: Any, to destination: Int) {
        guard let realElement = element as? Model else { return }
        guard let index = self.index(of: realElement) else { return }
        self.move(from: index, to: destination)
    }
    
    //MARK: -
    public func reload() {
        self.delegate?.reload()
    }
    
    public func reload(_ element: Any, animated: Bool) {
        guard let realElement = element as? Model else { return }
        self.reload(realElement, animated: true)
    }
    
    public func reload(contentsOf models: [Any], animated: Bool) {
        guard let realElements = models as? [Model] else { return }
        self.reload(models, animated: true)
    }
    
    //MARK: -
    public func update(_ block: () -> (), completion: (() -> ())?) {
        self.delegate?.update(block, completion: completion)
    }
    
    public func update(_ block: () -> ()) {
        self.delegate?.update(block, completion: nil)
    }
    
    //MARK: - Navigation
    public func scrollToBegining() {
        self.delegate?.scrollToTop()
    }
    
    public func scrollToEnd() {
        self.delegate?.scrollToBottom()
    }
}
