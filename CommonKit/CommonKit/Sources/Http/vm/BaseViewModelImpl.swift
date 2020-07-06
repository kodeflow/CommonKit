//
//  BaseViewModel.swift
//  CommonKit
//
//  Created by codeflow on 2020/5/6.
//  Copyright © 2020 codeflow. All rights reserved.
//

import Foundation
import RxSwift
import Moya

open class  BaseViewModelImpl<T: TargetType> {
    public let disposeBag = DisposeBag()
    
    private var api: MoyaProvider<T>
    public init(api: MoyaProvider<T>) {
        self.api = api
    }
    
    public func load(action: T) -> Single<Any> {
        return api.rx.request(action).mapJSON()
    }
}
