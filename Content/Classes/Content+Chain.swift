//
//  Content+Chain.swift
//  Pods
//
//  Created by Vlad Gorbenko on 10/6/16.
//
//

// Setup
public extension Content {
    @discardableResult
    func on(cellDequeue block: @escaping (_ model: Model) -> Cell.Type?) -> Content<Model, View, Cell> {
        self.callbacks.onDequeueBlock = block
        return self
    }
    
    @discardableResult
    func on(cellSetup block: @escaping (_ model: Model, _ cell: Cell) -> Void) -> Content<Model, View, Cell> {
        self.callbacks.onCellSetupBlock = block
        return self
    }
    
    @discardableResult
    func on(cellDisplay block: @escaping (_ model: Model, _ cell: Cell) -> Void) -> Content<Model, View, Cell> {
        self.callbacks.onCellDisplay = block
        return self
    }
    
    @discardableResult
    func on(setup block: @escaping (_ content: Content<Model, View, Cell>) -> Void) -> Content<Model, View, Cell> {
        self.callbacks.onSetupBlock = block
        block(self)
        return self
    }
    
    @discardableResult
    func on(height block: @escaping (_ model: Model) -> CGFloat?) -> Content<Model, View, Cell> {
        self.callbacks.onHeight = block
        return self
    }
    
    @discardableResult
    func on(estimatedHeight block: @escaping (_ model: Model) -> CGFloat?) -> Content<Model, View, Cell> {
        self.callbacks.onEstimatedHeight = block
        return self
    }
}

// Actions
public extension Content {
    @discardableResult
    func on(select block: @escaping ((Content<Model, View, Cell>, Model, Cell) -> Void)) -> Content<Model, View, Cell> {
        self.actions.onSelect = block
        return self
    }
    
    @discardableResult
    func on(shouldSelect block: @escaping ((Content<Model, View, Cell>, Model, Cell) -> Bool)) -> Content<Model, View, Cell> {
        self.actions.onShouldSelect = block
        return self
    }
    
    @discardableResult
    func on(deselect block: @escaping ((Content<Model, View, Cell>, Model, Cell) -> Void)) -> Content<Model, View, Cell> {
        self.actions.onDeselect = block
        return self
    }
    
    @discardableResult
    func on(action block: @escaping ((Content<Model, View, Cell>, Model, Cell, _ action: Action, _ params: [String: Any]) -> Void)) -> Content<Model, View, Cell> {
        self.actions.onAction = block
        return self
    }
    
    @discardableResult
    func on(delete block: @escaping ((Content<Model, View, Cell>, Model, Cell) -> Void)) -> Content<Model, View, Cell> {
        self.actions.onDelete = block
        return self
    }
    
    @discardableResult
    func on(add block: @escaping ((Content<Model, View, Cell>, Model, Cell) -> Void)) -> Content<Model, View, Cell> {
        self.actions.onAdd = block
        return self
    }
}

// Loading
public extension Content {
    @discardableResult
    func on(load block: @escaping ((_ content: Content<Model, View, Cell>) -> Void)) -> Content<Model, View, Cell> {
        self.URLCallbacks.onLoad = block
        return self
    }
}

// Raising
public extension Content {
    func raise(_ action: Action, sender: ContentCell) {
        self.raise(action, sender: sender, params: [:])
    }
    
    func raise(_ action: Action, sender: ContentCell, params: [String: Any]) {
        if let cell = sender as? Cell, let indexPath = self.delegate?.indexPath(cell) {
            self.actions.onAction?(self, self.items[(indexPath as NSIndexPath).row], cell, action, params)
        }
    }
}

//CollectionView applicable
public extension Content where View: UICollectionView {
    @discardableResult
    func on(pageChange block: @escaping (Content<Model, View, Cell>, Model, Int) -> Void) -> Content {
        self.callbacks.onItemChanged = block
        return self
    }
    
    @discardableResult
    func on(layout block: @escaping ((_ content: Content<Model, View, Cell>, Model) -> CGSize)) -> Content<Model, View, Cell> {
        self.callbacks.onLayout = block
        return self
    }
}

//Views
public extension Content {
    @discardableResult
    func on(headerDequeue block: @escaping (Content<Model, View, Cell>, Int) -> UIView?) -> Content {
        self.viewDelegateCallbacks.onHeaderViewDequeue = block
        return self
    }
    
    @discardableResult
    func on(headerDequeue block: @escaping (Content<Model, View, Cell>, Int) -> String?) -> Content {
        self.viewDelegateCallbacks.onHeaderDequeue = block
        return self
    }
    
    @discardableResult
    func on(footerDequeue block: @escaping (Content<Model, View, Cell>, Int) -> UIView?) -> Content {
        self.viewDelegateCallbacks.onFooterViewDequeue = block
        return self
    }
    
    @discardableResult
    func on(footerDequeue block: @escaping (Content<Model, View, Cell>, Int) -> String?) -> Content {
        self.viewDelegateCallbacks.onFooterDequeue = block
        return self
    }
}

//ScrollView applicable
public extension Content where View: UIScrollView {
    @discardableResult
    func on(didScroll block: ((Content<Model, View, Cell>) -> Void)?) -> Content {
        self.scrollCallbacks.onDidScroll = block
        return self
    }
    
    @discardableResult
    func on(didEndDecelerating block: ((Content<Model, View, Cell>) -> Void)?) -> Content {
        self.scrollCallbacks.onDidEndDecelerating = block
        return self
    }
    
    @discardableResult
    func on(didStartDecelerating block: ((Content<Model, View, Cell>) -> Void)?) -> Content {
        self.scrollCallbacks.onDidStartDecelerating = block
        return self
    }
    
    @discardableResult
    func on(didEndDragging block: ((Content<Model, View, Cell>, Bool) -> Void)?) -> Content {
        self.scrollCallbacks.onDidEndDragging = block
        return self
    }
    
}
