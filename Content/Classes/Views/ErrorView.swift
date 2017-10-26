//
//  ErrorView.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

public protocol ContentErrorView {
    func setup<Model: Equatable, View: ViewDelegate & UIView, Cell: ContentCell>(content: Content<Model, View, Cell>)
}

class ErrorView: UIView, ContentErrorView {
    
    internal lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Sorry. Something went wrong"
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
//        self.backgroundColor = UIColor.yellow.withAlphaComponent(0.4)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel.sizeToFit()
        self.textLabel.center = self.frame.center
        
        self.retryButton.sizeToFit()
        var center = self.frame.center
        center.y = center.y + self.textLabel.frame.height + 16
        self.retryButton.center = center
    }
    
    //MARK: - Setups
    public func setup<Model: Equatable, View: ViewDelegate & UIView, Cell: ContentCell>(content: Content<Model, View, Cell>) {
        // stub
        self.retryButton.addTarget(content, action: #selector(Content<Model, View, Cell>.refresh), for: .touchUpInside)
    }
    
}
