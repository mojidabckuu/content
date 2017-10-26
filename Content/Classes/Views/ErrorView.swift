//
//  ErrorView.swift
//  Alamofire
//
//  Created by Vlad Gorbenko on 27/10/2017.
//

import Foundation

class ErrorView: UIView {
    
    internal lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Sorry. Something went wrong"
        label.textColor = .black
        self.addSubview(label)
        return label
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
    
    //MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel.frame = self.bounds
    }
    
    //MARK: - Setups
    private func setup() {
        // stub
    }
    
}
