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

class User: Equatable, CustomStringConvertible {
    var name: String
    var avatarURL: URL
    
    init(name: String, avatarURL: URL) {
        self.name = name
        self.avatarURL = avatarURL
    }
    
    var description: String {
        return "\(self.name), \(self.avatarURL.absoluteString)"
    }
}

extension User {
    class func index(_ block: @escaping (([User]) -> Void)) {
        let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            let users = [User(name: "Darwin", avatarURL: URL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!),
                         User(name: "Leo", avatarURL: URL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!)]
            block(users)
        }
    }
    
    func posts(_ block: @escaping (([Post]) -> Void)) {
        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            var posts: [Post] = []
            posts.append(Post(text: "This is my post1", imageURL: URL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!))
            posts.append(Post(text: "This is my post2", imageURL: URL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!))
            posts.append(Post(text: "This is my post3", imageURL: URL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!))
            posts.append(Post(text: "This is my post4", imageURL: URL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!))
            block(posts)
        }
    }
}
