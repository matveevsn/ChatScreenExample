//
//  UserData.swift
//  ChatExample
//
//  Created by Sergey Matveev on 12.02.2021.
//

import Foundation

struct UserData: Codable {
    let sid: String
    let nickName: String
    let avatar: String?

    init(sid: String, nickName: String) {
        self.sid = sid
        self.nickName = nickName
        self.avatar = nil
    }
}
