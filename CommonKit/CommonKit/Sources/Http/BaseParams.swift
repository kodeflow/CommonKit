//
//  BaseParams.swift
//  CommonKit
//
//  Created by codeflow on 2020/5/6.
//  Copyright © 2020 codeflow. All rights reserved.
//

import ObjectMapper

open class BaseParams: Mappable {
    public required init?(map: Map) {}
    public func mapping(map: Map) {}
    public init() {}
    public func isValid() -> Bool { return false }
}
