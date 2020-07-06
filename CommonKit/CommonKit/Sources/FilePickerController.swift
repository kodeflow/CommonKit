//
//  FilePickerController.swift
//  CommonKit
//
//  Created by codeflow on 2020/4/18.
//  Copyright © 2020 codeflow. All rights reserved.
//

import UIKit
import SnapKit

public protocol FilePickerControllerDelegate {
    func filePicker(_ picker: FilePickerController, didSelect url: URL?, and data: Data?)
    func filePicker(_ picker: FilePickerController, didFailedWith err: FilePickError)
}

public enum FilePickerStyle: String {
    case camera = "拍照"
    case galery = "相册"
    case file = "文件"
}

public class FilePickerController: UIAlertController {
    public var obj: Any?
    /// 控制actionSheet弹出的项，目前支持【拍照，相册，文件】
    public var items: [FilePickerStyle] = [.camera, .galery, .file]
    /// 控制可以选择的文件类型
    public var UTIs = ["public.content", "public.text", "public.source-code ", "public.image", "public.audiovisual-content", "com.adobe.pdf", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.ppt"
    ]
    /// 用于选择文件后的回调，在filePicker(_ picker: , didSelect url: , and)中处理选择的文件
    public var delegate: FilePickerControllerDelegate?
    
    private var _root: UIViewController?
    private var root: UIViewController? {
        get {
            guard let _ = self._root else {
                var root: UIViewController?
                if #available(iOS 13, *) {
                    root = UIApplication.shared.windows.first?.rootViewController
                } else {
                    root = UIApplication.shared.keyWindow?.rootViewController
                }
                    
                while (root?.presentingViewController != nil) {
                    root = root?.presentingViewController
                }
                self._root = root
                return self._root
            }
            return self._root
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = delegate else {
            fatalError("没有实现 FilePickerControllerDelegate 代理")
        }
        
        for item in items {
            super.addAction(UIAlertAction(title: item.rawValue, style: .default, handler: { (_) in
                switch item {
                case .camera:
                    self.takeCamera()
                case .galery:
                    self.takeGalery()
                case .file:
                    self.takeFile()
                }
            }))
        }
        super.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
    }
    
    public override func addAction(_ action: UIAlertAction) {
        fatalError("请使用 items 属性来控制样式")
    }
}

public extension FilePickerController {
    /// 直接拍照（不显示界面）
    func takeCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            DispatchQueue.main.async {
                self.takeGalery()
            }
            return
        }
        let  cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.allowsEditing = false
        cameraPicker.sourceType = .camera
        //在需要的地方present出来
        root?.present(cameraPicker, animated: true, completion: nil)
    }
    
    /// 直接读取相册（不显示界面）
    func takeGalery() {
        let  cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.allowsEditing = false
        cameraPicker.sourceType = .photoLibrary
//        let button = UIButton(type: .custom)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
//        button.setTitleColor(view.tintColor, for: .normal)
//        button.setTitle("取消", for: .normal)
//        button.addTarget(self, action: #selector(self.actionBack(_:)), for: .touchUpInside)
//        cameraPicker.navigationBar.addSubview(button)
//        button.snp.makeConstraints({ (make) in
//            make.centerY.equalToSuperview()
//            make.trailing.equalToSuperview().offset(-15)
//        })
        //在需要的地方present出来
        root?.present(cameraPicker, animated: true, completion: nil)
    }
    
    /// 直接选取文件（不显示界面）
    func takeFile() {
        let documentController = DocumentPickerController(documentTypes: UTIs, in: .open)
        documentController.modalPresentationStyle = .formSheet
        documentController.delegate = self
        
        root?.present(documentController, animated: true, completion: nil)
        
    }
    
    @objc private func actionBack(_ sender: Any) {
        root?.dismiss(animated: true, completion: nil)
    }
}

// 处理用户选择的数据
extension FilePickerController: UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        root?.dismiss(animated: true, completion: nil)
        delegate?.filePicker(self, didFailedWith: .cancel)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        root?.dismiss(animated: true, completion: nil)
        if let url = info[.imageURL] as? URL {
            delegate?.filePicker(self, didSelect: url, and: nil)
        } else if let image = info[.originalImage] as? UIImage {
            delegate?.filePicker(self, didSelect: nil, and: image.pngData())
        } else {
            delegate?.filePicker(self, didFailedWith: .readFailedError)
        }
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            // 授权文件失败 grantFailedError
            delegate?.filePicker(self, didFailedWith: .grantFailedError)
            return
        }
        
        // 处理文件
        NSFileCoordinator().coordinate(readingItemAt: url, options: [], error: nil) { (newUrl) in
            do {
                let data = try Data(contentsOf: newUrl, options: .mappedIfSafe)
                let writedTo = data.write(as: newUrl.lastPathComponent)
                delegate?.filePicker(self, didSelect: writedTo, and: data)
            } catch {
                // 读取失败 readFailedError
                delegate?.filePicker(self, didFailedWith: .readFailedError)
            }
        }
        
        // 结束文件访问
        url.stopAccessingSecurityScopedResource()
    }
    
}

public enum FilePickError: String {
    case grantFailedError
    case readFailedError
    case cancel
    case OtherError
}
extension FilePickError: Swift.Error{

}

fileprivate extension Data {
    func write(as fileName: String? = nil) -> URL? {
        // 放在tmp文件夹下，可以被及时清除
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let targetName = fileName ?? randomName()
        let targetURL = temporaryDirectory.appendingPathComponent(targetName)
        do {
            try self.write(to: targetURL)
            return targetURL
        } catch {
            return nil
        }
    }
    
    private func randomName() -> String {
        return "\(Date().timeIntervalSince1970).jpg"
    }
}

fileprivate extension FileManager {
    func librayCachesURL() -> URL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask).first!
    }
}

public class DocumentPickerController: UIDocumentPickerViewController {
    public var obj: Any?
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: view.tintColor], for: .normal)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
    }
}
