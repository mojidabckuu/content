//
//  ErrorView.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

public protocol ContentView {
    func setup<Model: Equatable, View: ViewDelegate & UIView, Cell: ContentCell>(content: Content<Model, View, Cell>)
}

public protocol ErrorHandleable {
    func setup(error: Error)
}

public protocol ErrorView: ContentView, ErrorHandleable { }

public typealias ContentErrorView = ErrorView

class DefaultErrorView: UIView, ErrorView {
    
    internal lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Sorry. Something went wrong..."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        self.addSubview(label)
        return label
    }()
    
    internal lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        self.addSubview(button)
        return button
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        var frame = self.bounds
        frame.origin.x = 16
        frame.size.width = frame.size.width - 16 * 2
        let size = self.textLabel.sizeThatFits(frame.size)
        frame.size = size
        self.textLabel.frame = frame
        self.textLabel.center = self.frame.center
        
        self.retryButton.sizeToFit()
        var center = self.frame.center
        center.y = center.y + self.textLabel.frame.height + 16
        self.retryButton.center = center
    }
    
    //MARK: - Setups
    public func setup<Model: Equatable, View: ViewDelegate & UIView, Cell: ContentCell>(content: Content<Model, View, Cell>) {
        // stub
//        self.retryButton.addTarget(nil, action: nil, for: .allEvents)
        self.retryButton.addTarget(content, action: #selector(Content<Model, View, Cell>.refresh), for: .touchUpInside)
    }
    
    func setup(error: Error) {
        self.textLabel.text = error.localizedDescription
    }
    
}
