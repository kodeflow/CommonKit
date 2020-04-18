//
//  ViewController.swift
//  CommonKit
//
//  Created by codeflow on 2020/4/15.
//  Copyright © 2020 codeflow. All rights reserved.
//

import UIKit
import QuickLook

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!

    private var previewItems: [QLPreviewItem]?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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

