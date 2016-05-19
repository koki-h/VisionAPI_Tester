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
    func send(image:UIImage,callback:(data:NSData?, response:NSURLResponse?, error:NSError?)->())
    var result:String {get}
}

class ImageUtil {
    static func resizeImage(imageSize: CGSize, image: UIImage) -> NSData {
        UIGraphicsBeginImageContext(imageSize)
        image.drawInRect(CGRectMake(0, 0, imageSize.width, imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}
