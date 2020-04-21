//
//  Callbacks.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

public class ContentActionsCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    public internal(set) var onSelect: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    public internal(set) var onDeselect: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    public internal(set) var onShouldSelect: ((Content<Model, View, Cell>, Model, Cell) -> Bool)?
    public internal(set) var onAction: ((Content<Model, View, Cell>, Model, Cell, Action) -> Void)?
    public internal(set) var onAdd: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    public internal(set) var onDelete: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
}

class ContentURLCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    var onLoad: ((Content<Model, View, Cell>) -> Void)?
    var willLoad: (() -> Void)?
    var didLoad: ((Content<Model, View, Cell>, [Model]) -> Void)?
    //    var didLoad: ((Error?, [Model]) -> Void)?
    
    var beforeRefresh: ((Content<Model, View, Cell>) -> ())?
    var afterRefresh: ((Content<Model, View, Cell>) -> ())?
    var whenRefresh: ((Content<Model, View, Cell>) -> ())?
    
    var errorView: ((Content<Model, View, Cell>, Error) -> (UIView?))?
    var emptyView: ((Content<Model, View, Cell>) -> (UIView?))?
}

public final class ContentCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    public internal(set) var onHeight: ((Model) -> CGFloat?)?
    public internal(set) var onEstimatedHeight: ((Model) -> CGFloat?)?
    public internal(set) var onCellSetupBlock: ((Model, Cell) -> Void)?
    public internal(set) var onCellDisplay: ((Model, Cell) -> Void)?
    public internal(set) var onLayout: ((Content<Model, View, Cell>, Model) -> CGSize)?
    public internal(set) var onItemChanged: ((Content<Model, View, Cell>, Model, Int) -> Void)?
    public internal(set) var onDequeueBlock: ((Model) -> Cell.Type?)?
}

class ScrollCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    var onShouldScrollToTop: ((Content<Model, View, Cell>) -> Bool)?
    var onDidScroll: ((Content<Model, View, Cell>) -> Void)?
    var onDidEndDecelerating : ((Content<Model, View, Cell>) -> Void)?
    var onDidStartDecelerating : ((Content<Model, View, Cell>) -> Void)?
    var onDidEndDragging: ((Content<Model, View, Cell>, Bool) -> Void)?
}

class ViewDelegateCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    var onHeaderViewDequeue: ((Content<Model, View, Cell>, Int) -> UIView?)?
    var onHeaderDequeue: ((Content<Model, View, Cell>, Int) -> String?)?
    var onFooterViewDequeue: ((Content<Model, View, Cell>, Int) -> UIView?)?
    var onFooterDequeue: ((Content<Model, View, Cell>, Int) -> String?)?
}
