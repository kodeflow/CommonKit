//
//  ViewController.swift
//  CommonKit
//
//  Created by codeflow on 2020/4/15.
//  Copyright © 2020 codeflow. All rights reserved.
//

import UIKit
import QuickLook
import ObjectMapper
import Moya

class Hero: Mappable {
    var hp: String?
    var mp: String?
    required init?(map: Map) {}
    func mapping(map: Map) {
        hp <- map["hp"]
        mp <- map["mp"]
    }
}
class Person: Mappable {
    required init?(map: Map) {}
    init() {}
    var age: Int?
    var name: String?
    var hero: Hero?
    private var tag: Any?
    func mapping(map: Map) {
        age <- map["age"]
        name <- map["name"]
        hero <- map["hero"]
    }
}

enum Api {
    case login(paramLogin: ParamLogin)
}

extension Api: TargetType {
    
    var path: String {
        switch self {
        case .login:
            return "system/loginApp"
        }
    }
    
    var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case let .login(paramLogin):
            params.merge(paramLogin.toJSON()) { (current, _) in current }
        }
        
        return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
    }
}
extension Api {
     var baseURL: URL {
            return URL(string: "http://120.76.219.30:8000/")!
        }
        
        var method: Moya.Method {
            return .post
        }
        
        var sampleData: Data {
            return "".data(using: .utf8)!
        }
        
        var headers: [String : String]? {
            let header = ["Content-type": "application/json"]
//            let user = User.default
//            // 添加 token到header中
//            if let token = user.token {
//                header["Authorization"] = token
//            }
            return header
        }
}

fileprivate extension String {
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
    
    func isValidField() -> Bool {
        guard count > 0, self != "--请选择--" else {
            return false
        }
        return true
    }
}

let api = MoyaProvider<Api>()

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!

    let vm = LoginViewModel()
    private var previewItems: [QLPreviewItem]?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let person = Person(JSON: ["name": "John S.M", "age": 28, "hero": ["hp":"hp", "mp": "mp"]])
        let json = person?.toJSON()
        print(json)
        let someone = Person()
        someone.age = 18
        someone.name = "Someone"
        print("someone: \(someone.toJSON())")
        
        let param = ParamLogin()
        param.userName = "shimm"
        param.password = "1234"
        
        vm.login(paramLogin: param).subscribe(onNext: { a in
            print(a.toJSON())
        }, onError: { e in
            print(e)
        }).disposed(by: vm.disposeBag)
    }


}

extension ViewController {
    @IBAction func actionHandleTap(_ sender: Any) {
        // 1. 如果你需要展示FilePicker界面
        let alert = FilePickerController(title: nil, message: "请选择附件", preferredStyle: .actionSheet)
        alert.delegate = self
        alert.items = [.galery, .file]
        alert.takeCamera()
        // 不能使用UIAlertController.addAction方法
        // alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
        // 2. 不显示界面，直接拍照
//        takeCamera()
    }
    
    // 不显示界面，直接拍照
    private func takeCamera() {
        let alert = FilePickerController()
        alert.delegate = self
        alert.takeCamera()
    }
    
    @IBAction func actionPreview(_ sender: Any) {
        guard let items = previewItems, items.count > 0 else { return }
        let preview = QLPreviewController()
        preview.delegate = self
        preview.dataSource = self
        
        present(preview, animated: true, completion: nil)
    }
}

extension ViewController: FilePickerControllerDelegate {
    func filePicker(_ picker: FilePickerController, didSelect url: URL?, and data: Data?) {
        button.setTitle(url?.lastPathComponent, for: .normal)
        if let u = url {
            previewItems = [u as QLPreviewItem]
        }
    }
    
    func filePicker(_ picker: FilePickerController, didFailedWith err: FilePickError) {
        
    }
}

extension ViewController: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewItems?.count ?? 0
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItems![index]
    }
    
    
}

