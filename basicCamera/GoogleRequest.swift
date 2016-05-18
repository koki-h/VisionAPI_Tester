//
//  GoogleRequest.swift
//  basicCamera
//
//  Created by koki on 2016/05/17.
//  Copyright © 2016年 koki. All rights reserved.
//

import Foundation
import UIKit

class GoogleRequest: NSObject,APIRequest {
    var key: String = APIkeys.GoogleKey
    var result: String = ""
    
    func send(image: UIImage,callback:(data:NSData?, response:NSURLResponse?, error:NSError?)->()) {
        let imagedata:String = base64EncodeImage(image) // 画像をJSONに入れるためにbase64エンコードする
        let request = createRequest(imagedata)
        let session = NSURLSession.sharedSession()
        // run the request
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            callback(data: data,response: response, error: error)
            if (data != nil && data!.length != 0 && error == nil) {
                do {
                    let result_dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                    self.result = result_dict.description
                } catch {
                    self.result = "Google API JSON Parse Error.¥n" + String.init(data: data!, encoding: NSUTF8StringEncoding)!
                }
                NSLog("Google:%@",String.init(data: data!, encoding: NSUTF8StringEncoding)!)
            } else {
                NSLog("Google:%@",error!)
                self.result = "Google API Error." + error!.localizedDescription
            }
        })
        task.resume()
    }
    
    func base64EncodeImage(image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.length > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSizeMake(800, oldSize.height / oldSize.width * 800)
            imagedata = ImageUtil.resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
    }
    
    func createRequest(imageData: String) -> NSMutableURLRequest {
        // Create our request URL
        let request = NSMutableURLRequest(
            URL: NSURL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(key)")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(
            NSBundle.mainBundle().bundleIdentifier ?? "",
            forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest: [String: AnyObject] = [
            "requests": [
                "image": [
                    "content": imageData
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ],
                    [
                        "type": "FACE_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        
        // Serialize the JSON
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonRequest, options: [])
        
        return request
    }
}