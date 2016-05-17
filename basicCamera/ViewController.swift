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
    @IBOutlet weak var bSavePic: UIBarButtonItem!
    @IBOutlet weak var bAlbum: UIBarButtonItem!
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Tap the [Start] to take a picture."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cameraStart(sender: AnyObject) {
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
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
            
        }
        
        //閉じる処理
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        label.text = "Tap the [Save] to save a picture"
        
    }
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        label.text = "Canceled"
    }
    
    @IBAction func savePic(sender: AnyObject) {
        let image:UIImage! = cameraView.image
        
        if image != nil {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        else{
            label.text = "image Failed !"
        }
    }
    
    // 書き込み完了結果の受け取り
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        print("1")
        
        if error != nil {
            print(error.code)
            label.text = "Save Failed !"
        }
        else{
            label.text = "Save Succeeded"
        }
    }
    
    @IBAction func showAlbum(sender: AnyObject) {
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.presentViewController(cameraPicker, animated: true, completion: nil)
            
            label.text = "Tap the [Start] to save a picture"
        }
        else{
            label.text = "error"
            
        }
    }
}

