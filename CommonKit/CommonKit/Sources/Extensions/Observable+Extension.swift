//
//  Observable+Extension.swift
//  CommonKit
//
//  Created by codeflow on 2020/5/6.
//  Copyright © 2020 codeflow. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

public var isDebug = false

extension Observable {
    
    public func mapObject<T: Mappable>(type:T.Type) -> Observable<T> {
        
        return self.map{ response in
            
            //if response is a dictionary, then use ObjectMapper to map the dictionary
            guard let dict = response as? [String:Any] else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            //if not throw an error
            if let error = self.parseError(response: dict){
                throw error
            }
            // 判断返回结构是否为 {code: , msg: , data: }
            if let dict = response as? [String: Any] {
                let code = dict["code"]
                let msg = dict["msg"]
                if code == nil || msg == nil {
                    throw RxSwiftMoyaError.ServerError
                }
            }
            
            let rawData = response as! [String: Any]
            if isDebug {
                print("----return result----")
                print(rawData)
            }
//            let code = rawData["code"] as! String
//            let msg = rawData["msg"] as! String
//            if "200" != code {
//                throw RxSwiftMoyaError.OtherError
//            }
//            let data = rawData["data"] as! [String : Any]
//            print("responseData=\(data)")
            
            return Mapper<T>().map(JSON: rawData)!
        }
    }
    
    public func mapArray<T:Mappable>(type:T.Type) ->Observable<[T]>{
        
        return self.map{ response in
            //if response is not a dictionary array, then throw an error
            guard let array = response as? [[String:Any]] else{
                throw RxSwiftMoyaError.ParseJSONError
            }
            
            // 返回值类型断言
            // 如果返回值为数组类型，则不需要通过<code> parseError(response:) </code>进行结构断言
            return Mapper<T>().mapArray(JSONArray: array)
        }
    }
    
    /// 验证返回数据的格式
    ///
    /// - Parameter response: 服务器返回的数据
    /// - Returns: 是否存在错误
    final fileprivate func parseError(response:[String :Any]?) -> NSError? {
    
        var error:NSError?
        
        if let value = response{
            var code:Int?
            var msg:String?
            
            if let errorDic = value["error"] as? [String:Any]{
                code = errorDic["code"] as? Int
                msg = errorDic["msg"] as? String
                error = NSError(domain: "Network", code: code!, userInfo: [NSLocalizedDescriptionKey:msg ?? ""])
            }
        }
        return error
    }
    
    final fileprivate func parseServerError() -> Observable {
        
        return self.map{ (response) in
            
            let name = type(of: response)
            if isDebug {
                print(name)
            }
            
            guard let dict = response as? [String:Any] else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            if let error = self.parseError(response: dict){
                throw error
            }
            return self as! Element
        }
    }
}

public enum RxSwiftMoyaError: String {
    case ParseJSONError
    case ServerError
    case OtherError
}
extension RxSwiftMoyaError: Swift.Error{

}
