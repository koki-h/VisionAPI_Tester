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
    
    @IBOutlet weak var bCameraStart: UIBarButtonItem!
    @IBOutlet weak var bGoogle: UIBarButtonItem!
    @IBOutlet weak var bMS: UIBarButtonItem!
    @IBOutlet weak var bIBM: UIBarButtonItem!
    @IBOutlet weak var label: UILabel!
    let resultLayer = CATextLayer()
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
        if current_result == API.Google {
            hideLayer()
            current_result = API.None
        } else {
            showLayer(r_google.result)
            current_result = API.Google
            
        }
    }
    
    @IBAction func showResultMS(sender: AnyObject) {
        showLayer("MS結果")
    }

    @IBAction func showResultIBM(sender: AnyObject) {
        showLayer("IBM結果")
    }
    
    func initLayer() {
        let marginSizeX = 10.0 as CGFloat
        let marginSizeY = 30.0 as CGFloat
        let layerWidth = cameraView.frame.width - marginSizeX * 2
        let layerHeight = cameraView.frame.height - marginSizeY * 2
        let layerX = cameraView.frame.origin.x + marginSizeX
        let layerY = cameraView.frame.origin.y + marginSizeY
        let layerBounds:CGRect = CGRectMake(layerX, layerY, layerWidth, layerHeight);
        
        resultLayer.backgroundColor = UIColor.blackColor().CGColor
        resultLayer.foregroundColor = UIColor.whiteColor().CGColor
        resultLayer.opacity = 0.5
        resultLayer.frame = layerBounds
        resultLayer.wrapped = true
        //resultLayer.font = ""
        resultLayer.fontSize=20.0
        resultLayer.contentsScale = UIScreen.mainScreen().scale
        self.view.layer.addSublayer(resultLayer);
        resultLayer.hidden = true
    }
    
    func showLayer(text:String) {
        resultLayer.string = text as AnyObject;
        resultLayer.hidden = false
    }
    
    func hideLayer() {
        resultLayer.hidden = true
    }
}

