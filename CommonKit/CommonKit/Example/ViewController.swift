//
//  ViewController.swift
//  CommonKit
//
//  Created by codeflow on 2020/4/15.
//  Copyright © 2020 codeflow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBAction func actionHandleTap(_ sender: Any) {
        let alert = FilePickerController(title: nil, message: "请选择附件", preferredStyle: .actionSheet)
        alert.delegate = self
        // 不能使用UIAlertController.addAction方法
        // alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

extension ViewController: FilePickerControllerDelegate {
    func filePicker(_ picker: FilePickerController, didSelect url: URL?, and data: Data?) {
        button.setTitle(url?.lastPathComponent, for: .normal)
    }
    
    func filePicker(_ picker: FilePickerController, didFailedWith err: FilePickError) {
        
    }
}

