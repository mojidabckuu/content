//
//  Post.swift
//  Content
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Content

func == (left: Post, right: Post) -> Bool {
    return left.text == right.text
}

final class Post: Equatable {
    var imageURL: URL!
    var text: String!
    
    init(text: String, imageURL: URL) {
        self.imageURL = imageURL
        self.text = text
    }
    
    required init() {}
}
