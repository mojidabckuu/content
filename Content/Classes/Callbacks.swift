//
//  Callbacks.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

class ContentActionsCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    var onSelect: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    var onDeselect: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    var onShouldSelect: ((Content<Model, View, Cell>, Model, Cell) -> Bool)?
    var onAction: ((Content<Model, View, Cell>, Model, Cell, Action) -> Void)?
    var onAdd: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
    var onDelete: ((Content<Model, View, Cell>, Model, Cell) -> Void)?
}

class ContentURLCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    var onLoad: ((Content<Model, View, Cell>) -> Void)?
    var willLoad: (() -> Void)?
    var didLoad: ((Error?, [Model]) -> Void)?
}

class ContentCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
    var onSetupBlock: ((Content<Model, View, Cell>) -> Void)?
    var onHeight: ((Model) -> CGFloat?)?
    var onEstimatedHeight: ((Model) -> CGFloat?)?
    var onCellSetupBlock: ((Model, Cell) -> Void)?
    var onCellDisplay: ((Model, Cell) -> Void)?
    var onLayout: ((Content<Model, View, Cell>, Model) -> CGSize)?
    var onItemChanged: ((Content<Model, View, Cell>, Model, Int) -> Void)?
    var onDequeueBlock: ((Model) -> Cell.Type?)?
}

class ScrollCallbacks<Model: Equatable, View: ViewDelegate, Cell: ContentCell> where View: UIView {
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
