//
//  Post.swift
//  Content
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

func == (left: Post, right: Post) -> Bool {
    return left.text == right.text
}

class Post: Equatable {
    var imageURL: NSURL
    var text: String
    
    init(text: String, imageURL: NSURL) {
        self.imageURL = imageURL
        self.text = text
    }
}
