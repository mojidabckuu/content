//
//  User.swift
//  Content
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

func == (left: User, right: User) -> Bool {
    return left.name == right.name
}

class User: Equatable {
    var name: String
    var avatarURL: NSURL
    
    init(name: String, avatarURL: NSURL) {
        self.name = name
        self.avatarURL = avatarURL
    }
}

extension User {
    class func index(block: ([User] -> Void)) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            let users = [User(name: "Darwin", avatarURL: NSURL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!),
                         User(name: "Leo", avatarURL: NSURL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!)]
            block(users)
        }
    }
    
    func posts(block: ([Post] -> Void)) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            var posts: [Post] = []
            posts.append(Post(text: "This is my post1", imageURL: NSURL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!))
            posts.append(Post(text: "This is my post2", imageURL: NSURL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!))
            posts.append(Post(text: "This is my post3", imageURL: NSURL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!))
            posts.append(Post(text: "This is my post4", imageURL: NSURL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!))
            block(posts)
        }
    }
}