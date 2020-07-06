//
//  ParamLogin.swift
//  CommonKit
//
//  Created by codeflow on 2020/5/6.
//  Copyright © 2020 codeflow. All rights reserved.
//

import ObjectMapper

class ParamLogin: BaseParams {
    var userName: String?
    var password: String?
    override func mapping(map: Map) {
        userName <- map["userName"]
        password <- map["password"]
    }
    
    override func isValid() -> Bool {
        return (userName?.count ?? 0) > 0 && (password?.count ?? 0) > 0
    }
}
