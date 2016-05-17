//
//  APIRequest.swift
//  basicCamera
//
//  Created by koki on 2016/05/17.
//  Copyright © 2016年 koki. All rights reserved.
//

import Foundation
import UIKit

protocol APIRequest {
    func send(image:UIImage,callback:(data:NSData, response:NSURLResponse, error:NSError?)->())
    var result:String {get}
    var key:String {set get}
}

class RequestSender {
    static func send(request: NSMutableURLRequest,
                     callback:(data:NSData, response:NSURLResponse, error:NSError?)->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let session = NSURLSession.sharedSession()
            // run the request
            let task = session.dataTaskWithRequest(request, completionHandler: {
                data, response, error -> Void in
                callback(data: data!,response: response!, error: error)
            })
            task.resume()
        })
    }
}