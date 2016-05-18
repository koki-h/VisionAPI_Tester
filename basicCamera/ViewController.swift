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
    //let resultLayer = CATextLayer()
    enum API{
        case None
        case Google
        case MS
        case IBM
    }
    var current_result:API = API.None
    let r_google = GoogleRequest()
    
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
            r_google.send(pickedImage, callback: {_,_,_ in 
                dispatch_async(dispatch_get_main_queue()) {
                    self.bGoogle.enabled = true
                    self.label.text = ""
                }
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
        let text = "MS結果"
        toggleLayer(API.MS, text: text)
    }

    @IBAction func showResultIBM(sender: AnyObject) {
        let text = "IBM結果"
        toggleLayer(API.IBM, text: text)
    }
    
    private func toggleLayer(api_type:API, text:String) {
        if current_result == api_type {
            hideLayer()
            current_result = API.None
        } else {
            showLayer(text)
            current_result = api_type
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
