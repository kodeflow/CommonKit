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

class BaseViewModel: BaseViewModelImpl<Api> {
    init() {
        super.init(api: api)
    }
}
