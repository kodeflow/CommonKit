//
//  BaseModel.swift
//  CommonKit
//
//  Created by codeflow on 2020/5/6.
//  Copyright © 2020 codeflow. All rights reserved.
//

import ObjectMapper

open class BaseModel<T: Mappable>: ModelInterface<T> {
    open var data: T?
    public override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

open class BaseArrayModel<T: Mappable>: ModelInterface<T> {
    open var data: [T]?
    public override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

open class ModelInterface<T: Mappable>: Mappable {
    open var code: String?
    open var msg: String?
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        code    <- map["code"]
        msg     <- map["msg"]
    }
}

open class PlainResult: Mappable {
    open var code: String?
    open var msg: String?
    open var data: String?
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        code <- map["code"]
        msg  <- map["msg"]
        data <- map["data"]
    }
}
