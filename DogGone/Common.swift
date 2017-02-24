//
//  Common.swift
//  DogGone
//
//  Created by Love Mob on 12/8/16.
//  Copyright © 2016 Love Mob. All rights reserved.
//

import UIKit
import Foundation
import MapKit


class Common: NSObject, UIAlertViewDelegate {
    
    func methodForAlert (titleString:String, messageString:String, OKButton:String, CancelButton:String, viewController: UIViewController){
        let alertController = UIAlertController(title: titleString, message: messageString, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: CancelButton, style: UIAlertActionStyle.cancel) {
            (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        if (CancelButton != ""){
            alertController.addAction(cancelAction)
        }
        
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func X(view: UIView) -> CGFloat{
        return view.frame.origin.x
    }
    
    func Y(view: UIView) -> CGFloat{
        return view.frame.origin.y
    }
    
    func WIDTH(view: UIView) -> CGFloat{
        return view.bounds.size.width
    }
    
    func HEIGHT(view: UIView) -> CGFloat{
        return view.bounds.size.height
    }
    
    func methodIsValidEmailAddress(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if emailTest.evaluate(with: email) != true {
            return false
        }
        else {
            return true
        }
    }
    
    func methodIsValidFloat(val: String) -> Bool{
        let val_flt = Float(val)
        return (val_flt != nil)
    }
}

extension UIImage{
    
    func resize(_ size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        return redraw(in: rect)
    }
    
    func redraw(in rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return nil }
        
        context.draw(cgImage, in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    var flippedHorizontally: UIImage { return UIImage(cgImage: self.cgImage!, scale: self.scale, orientation: .downMirrored) }
    var flippedVertically: UIImage { return UIImage(cgImage: self.cgImage!, scale: self.scale, orientation: .rightMirrored) }
    
    func circled(forRadius radius: CGFloat) -> UIImage? {
        let rediusSize = CGSize(width: radius, height: radius)
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let bezierPath = UIBezierPath(roundedRect: rect, byRoundingCorners: [.allCorners], cornerRadii: rediusSize)
        context.addPath(bezierPath.cgPath)
        context.clip()
        
        draw(in: rect)
        context.drawPath(using: .fillStroke)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

class ImageProcessing: NSObject{
    
    func makeRoundedImage(image: UIImage, radius: Float) -> UIImage {
        let img = image.resize(CGSize(width: CGFloat(radius), height: CGFloat(radius)))?.circled(forRadius: CGFloat(radius))
        let roundedImage = img?.flippedHorizontally
        return roundedImage!
    }
    
    func makeMergeImage(bottomImage: UIImage, topImage: UIImage) -> UIImage{
        let size = CGSize(width: 111.3, height: 147.7)
        UIGraphicsBeginImageContext(size)
        
        let areaSize00 = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let areaSize01 = CGRect(x: 16, y: 13, width: 80, height: 80)
        bottomImage.draw(in: areaSize00)
        topImage.draw(in: areaSize01, blendMode: .normal, alpha: 1)
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func makeMergeImageForOtherUsers(bottomImage: UIImage, topImage: UIImage) -> UIImage{
        let size = CGSize(width: 102.2, height: 147.7)
        UIGraphicsBeginImageContext(size)
        
        let areaSize00 = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let areaSize01 = CGRect(x: 12, y: 20, width: 80, height: 80)
        bottomImage.draw(in: areaSize00)
        topImage.draw(in: areaSize01, blendMode: .normal, alpha: 1)
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func getImageFromURL(imgName: String) -> UIImage{
        var img: UIImage = #imageLiteral(resourceName: "male.jpeg")
        if (!imgName.trimmingCharacters(in: .whitespaces).isEmpty){
            let profilePictureURLStr = String(kAPI_URL)! + imgName
            let url = NSURL(string: profilePictureURLStr)
            if let data = NSData(contentsOf: url as! URL){
                img = UIImage(data:data as Data)!
            }
        }
        
        return img
    }
}
