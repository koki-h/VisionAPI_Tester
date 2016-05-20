//
//  MSRequest.swift
//  basicCamera
//
//  Created by koki on 2016/05/18.
//  Copyright © 2016年 koki. All rights reserved.
//

import Foundation
import UIKit

// for Microsoft Cognitive Services Computer Vision API
// https://www.microsoft.com/cognitive-services/en-us/computer-vision-api

class MSRequest: NSObject,APIRequest {
    var result = ""
    
    func send(image:UIImage,callback:(data:NSData?, response:NSURLResponse?, error:NSError?)->()) {
        let request = createRequest()
        var imagedata = UIImageJPEGRepresentation(image,1.0)
        
        // Resize the image if it exceeds the 4MB API limit
        if (imagedata?.length > 4194304) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSizeMake(800, oldSize.height / oldSize.width * 800)
            imagedata = ImageUtil.resizeImage(newSize, image: image)
        }
        
        let start_time = NSDate()
        let session = NSURLSession.sharedSession()
        let task = session.uploadTaskWithRequest(request, fromData: imagedata!, completionHandler: {
            data, response, error -> Void in
            let response_time = abs(Float(start_time.timeIntervalSinceNow))
            self.result = "Response Time:" + String.init(response_time) + "s\n"
            callback(data: data,response: response, error: error)
            if (data != nil && error == nil) {
                do {
                    let result_dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                    self.result += result_dict.description
                } catch {
                    self.result += "MS API JSON Parse Error.\n" + String.init(data: data!, encoding: NSUTF8StringEncoding)!
                }
                NSLog("MS:%@",String.init(data: data!, encoding: NSUTF8StringEncoding)!)
            } else {
                NSLog("MS:%@",error!)
                self.result += "MS API Error." + error!.localizedDescription
            }
        })
        task.resume()
    }
    
    
    func createRequest()->NSMutableURLRequest {
        let key = APIkeys.MSKey
        let request = NSMutableURLRequest(
            URL: NSURL(string: "https://api.projectoxford.ai/vision/v1/analyses?visualFeatures=ALL")!)
        request.HTTPMethod = "POST"
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.addValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        return request
    }

}