//
//  User.swift
//  Content
//
//  Created by Vlad Gorbenko on 9/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Content

func == (left: User, right: User) -> Bool {
    return left.name == right.name
}

final class User: Equatable, CustomStringConvertible {
    
    static var modelName: String { return "user" }
    static var modelsName: String { return "users" }
    
    var name: String!
    var avatarURL: URL!
    
    init(name: String, avatarURL: URL) {
        self.name = name
        self.avatarURL = avatarURL
    }
    
    var description: String {
        return "\(self.name), \(self.avatarURL.absoluteString)"
    }
    
    required init() {}
    
    class func x() -> String { return "x" }
}

extension User {
    static var counter = 0
    class func index(_ block: @escaping (([User]) -> Void)) {
        let delayTime = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
//            let names = ["Darwin", "Leo", "Vinci", "Rafael", "Ioan", "Duma", "Victor", "Bah", "Mick", "Lorenco", "Donatello"]
            var users: [User] = []
            for _ in 0..<20 {
                counter = counter + 1
//                let name = i >= names.count ? "name\(counter)" : names[i]
                let name = "name\(counter)"
                let user = User(name: name, avatarURL: URL(string:"https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!)
                users.append(user)
            }
            block(users)
        }
    }
    
    func posts(_ block: @escaping (([Post]) -> Void)) {
        let delayTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            var posts: [Post] = []
            posts.append(Post(text: "This is my post1", imageURL: URL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!))
//            posts.append(Post(text: "This is my post2", imageURL: URL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!))
//            posts.append(Post(text: "This is my post3", imageURL: URL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!))
//            posts.append(Post(text: "This is my post4", imageURL: URL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=350%C3%97150&w=350&h=150")!))
            block(posts)
        }
    }
}
