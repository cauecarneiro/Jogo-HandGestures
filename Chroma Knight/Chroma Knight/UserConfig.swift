//
//  UserConfig.swift
//  Chroma Knight
//
//  Created by Thiago Parisotto on 06/06/24.
//

import Foundation

class UserConfig {
    static let shared: UserConfig = UserConfig()
    var userPause: Bool
    
    init() {
        self.userPause = false
    }
    
    func changePause() {
        userPause.toggle()
    }
}
