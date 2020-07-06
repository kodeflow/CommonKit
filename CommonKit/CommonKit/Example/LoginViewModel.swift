//
//  LoginViewModel.swift
//  CommonKit
//
//  Created by codeflow on 2020/5/6.
//  Copyright © 2020 codeflow. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel: BaseViewModel {
    func login(paramLogin: ParamLogin) -> Observable<PlainResult> {
        return load(action: .login(paramLogin: paramLogin)).asObservable()
            .mapObject(type: PlainResult.self)
    }
}
