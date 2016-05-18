//
//  IBMReques.swift
//  basicCamera
//
//  Created by koki on 2016/05/18.
//  Copyright © 2016年 koki. All rights reserved.
//

import Foundation
import UIKit

// for IBM Watson Developer Cloud Visual Recognition
// http://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/visual-recognition.html

class IBMRequest: NSObject,APIRequest {
    let key      = ""
    let uname    = APIkeys.IBMUname
    let password = APIkeys.IBMPass
    var result:String = ""
    
    func send(image:UIImage,callback:(data:NSData?, response:NSURLResponse?, error:NSError?)->()) {
        let request = createRequest()
        var imagedata = UIImagePNGRepresentation(image)
        // とりあえず小さめに
        if (imagedata?.length > 2097152) {
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
            if (data != nil && data!.length != 0 && error == nil) {
                do {
                    let result_dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                    self.result += result_dict.description
                } catch {
                    self.result += "IBM API JSON Parse Error.\n" + String.init(data: data!, encoding: NSUTF8StringEncoding)!
                }
                NSLog("IBM:%@",String.init(data: data!, encoding: NSUTF8StringEncoding)!)
            } else {
                NSLog("IBM:%@",error!)
                self.result += "IBM API Error." + error!.localizedDescription
            }
        })
        task.resume()
    }

    func createRequest()->NSMutableURLRequest {
        let request = NSMutableURLRequest(
            URL: NSURL(string: "https://\(uname):\(password)@gateway.watsonplatform.net/visual-recognition-beta/api/v2/classify?version=2015-12-02")!)
        request.HTTPMethod = "POST"
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        return request
    }

}