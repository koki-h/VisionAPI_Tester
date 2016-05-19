//
//  ViewController.swift
//  basicCamera
//
//  Created by koki on 2016/05/15.
//  Copyright © 2016年 koki. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var scrollText: UITextView!
    
    @IBOutlet weak var bCameraStart: UIBarButtonItem!
    @IBOutlet weak var bGoogle: UIBarButtonItem!
    @IBOutlet weak var bMS: UIBarButtonItem!
    @IBOutlet weak var bIBM: UIBarButtonItem!
    @IBOutlet weak var label: UILabel!

    enum API{
        case None
        case Google
        case MS
        case IBM
    }
    var current_result:API = API.None
    let r_google = GoogleRequest()
    let r_ms = MSRequest()
    let r_ibm = IBMRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        current_result = API.None
        bGoogle.enabled = false
        bMS.enabled = false
        bIBM.enabled = false
        label.text = "[撮影] をタップして写真を撮ると自動的にAPIに問い合わせます"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initLayer()
    }
    
    @IBAction func cameraStart(sender: AnyObject) {
        current_result = API.None
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            bGoogle.enabled = false
            bMS.enabled = false
            bIBM.enabled = false
            self.presentViewController(cameraPicker, animated: true, completion: nil)
        }
        else{
            label.text = "error. No Camera."
        }
    }
    
    //　撮影が完了時した時に呼ばれる
    func imagePickerController(imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            cameraView.contentMode = .ScaleAspectFit
            cameraView.image = pickedImage
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.r_google.send(pickedImage, callback: {_,_,_ in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.bGoogle.enabled = true
                        self.label.text = ""
                    }
                })
                self.r_ms.send(pickedImage, callback: {_,_,_ in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.bMS.enabled = true
                        self.label.text = ""
                    }
                })
                self.r_ibm.send(pickedImage, callback: {_,_,_ in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.bIBM.enabled = true
                        self.label.text = ""
                    }
                })
            })
        }
        
        //閉じる処理
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        label.text = "APIに問い合わせ中.."
        // APIにリクエスト送信
        // TODO: 3つのAPIに並列でリクエストを送信する
        
    }
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        label.text = "Canceled"
    }
    
    @IBAction func showResultGoogle(sender: AnyObject) {
        toggleLayer(API.Google, text: r_google.result)
    }
    
    @IBAction func showResultMS(sender: AnyObject) {
        toggleLayer(API.MS, text: r_ms.result)
    }

    @IBAction func showResultIBM(sender: AnyObject) {
        toggleLayer(API.IBM, text: r_ibm.result)
    }
    
    private func toggleLayer(api_type:API, text:String) {
        if current_result == api_type {
            hideLayer()
            markActiveButton(API.None)
            current_result = API.None
        } else {
            showLayer(text)
            markActiveButton(api_type)
            current_result = api_type
        }
    }
    
    private func markActiveButton(api_type:API) {
        bGoogle.tintColor = bCameraStart.tintColor
        bMS.tintColor = bCameraStart.tintColor
        bIBM.tintColor = bCameraStart.tintColor
        switch api_type {
        case API.Google:
            bGoogle.tintColor = UIColor.redColor()
        case API.MS:
            bMS.tintColor = UIColor.redColor()
        case API.IBM:
            bIBM.tintColor = UIColor.redColor()
        default:
            break
        }
    }
    
    func initLayer() {
        scrollText.editable = false
        scrollText.hidden = true
    }
    
    func showLayer(text:String) {
        scrollText.text = text
        scrollText.hidden = false
    }
    
    func hideLayer() {
        scrollText.hidden = true
    }
}

