//
//  EmptyView.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

class DefaultEmptyView: UIView, ContentView {
    
    internal lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "No records"
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
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    deinit {
        print("Hello from deinit Empty")
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
    private func setup() {
        // stub
    }
    
    func setup<Model, View, Cell>(content: Content<Model, View, Cell>) where Model : Equatable, View : UIView, View : ViewDelegate, Cell : ContentCell {
        
    }
    
}
