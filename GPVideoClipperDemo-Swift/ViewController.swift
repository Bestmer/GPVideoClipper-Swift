//
//  ViewController.swift
//  GPVideoClipperDemo-Swift
//
//  Created by Roc Kwok on 2020/5/19.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Action
    
    @IBAction func testAction(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.albumAction()
                    break
                case .denied:
                    let controller = UIAlertController.init(title: "提示", message: "去打开权限", preferredStyle: .alert)
                    let leftAction = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
                        controller.dismiss(animated: true, completion: nil)
                    }
                    let rightAction = UIAlertAction.init(title: "打开", style: .destructive) { (action) in
                        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly:false], completionHandler: nil)
                        controller.dismiss(animated: true, completion: nil)
                    }
                    controller.addAction(leftAction)
                    controller.addAction(rightAction)
                    self.present(controller, animated: true, completion: nil)
                    break
                default:
                    break
                }
            }
        }
    }
    
    func albumAction() {
        let picker = UIImagePickerController.init()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = [kUTTypeMovie as String]
        self.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - <UIImagePickerControllerDelegate>
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let clipperController = GPVideoClipperController.clipperWithVideoURL(info[UIImagePickerController.InfoKey.mediaURL] as! URL, makerBlock: { (maker) in
            maker.startTime = 0
            maker.endTime = 15
            maker.clippedVideoMinDuration = 3
            maker.clippedVideoMaxDuration = 15
        }) { (videoURL, videoAsset, coverImage) in
            // handle videoURL，videoAsset，coverImage
            let alertController = UIAlertController.init(title: "提示", message: "视频保存成功，请前往相册中查看!", preferredStyle: .alert)
            let doneAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(doneAction)
            self.present(alertController, animated: true, completion: nil)
        }
        self.navigationController?.pushViewController(clipperController, animated: false)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

