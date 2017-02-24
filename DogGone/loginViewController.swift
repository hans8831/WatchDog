//
//  loginViewController.swift
//  DogGone
//
//  Created by Love Mob on 12/5/16.
//  Copyright © 2016 Love Mob. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import MBProgressHUD
import SwiftyJSON
//import MessageUI
import UserNotifications

class loginViewController: UIViewController{
    @IBOutlet weak var btn_facebook: UIButton!
    @IBOutlet var btn_email: UIButton!
    @IBOutlet var btn_phone: UIButton!
    @IBOutlet var ico_facebook: UIImageView!
    @IBOutlet var ico_email: UIImageView!
    @IBOutlet var ico_phone: UIImageView!
    
    @IBOutlet weak var view_facebook: UIView!
    @IBOutlet weak var view_email: UIView!
    @IBOutlet weak var view_phone: UIView!
    
    var loadingNotification: MBProgressHUD? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
        checkDefaultUser()
    }
    
    func checkDefaultUser(){
        let parameters = ["user_id":String(Owner.id),
                          "user_type":"4"]                  //For Update
        
        Alamofire.request(kAPI_Login, method: .get, parameters: parameters).responseString{ response in
            switch response.result{
            case .success(_):
                let rs:String = response.result.value!
                if(rs == "1"){                                      //exist User
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                else if(rs == "2"){                                 //Unexist User
                    //normal process.
                    Owner.initUserData()
                }
                break;
            case .failure(let error):
                print (error)
                Owner.initUserData()
                break;
            }
        }
    }
    
    func initComponents(){
        view_facebook.layer.borderWidth = 0.3
        view_facebook.layer.cornerRadius = 5.0
        view_facebook.layer.borderColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.6).cgColor

        view_email.layer.borderWidth = 0.3
        view_email.layer.cornerRadius = 5.0
        view_email.layer.borderColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.6).cgColor

        view_phone.layer.borderWidth = 0.3
        view_phone.layer.cornerRadius = 5.0
        view_phone.layer.borderColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.6).cgColor
    }
    func checkFaceBook(){
        if(FBSDKAccessToken.current() == nil){
            print("not log in")
        }
        else{
            print("log in")
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func connectWithFacebook(_ sender: Any) {
        Owner.user_type = 1
        
        self.disableUI(disable: true, message: kMsgLoginWithFaceBook)
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if((error) != nil){
                print("Facebook Login Error")
                self.disableUI(disable: false, message: kMsgLoginWithFaceBook)
            }
            else if (result?.isCancelled)!{
                print("Facebook Login Cancelled")
                self.disableUI(disable: false, message: kMsgLoginWithFaceBook)
            }
            else{
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        fbLoginManager.logOut()
                    }
                    else{
                        self.disableUI(disable: false, message: kMsgLoginWithFaceBook)
                    }
                }
                else{
                    self.disableUI(disable: false, message: kMsgLoginWithFaceBook)
                }
            }
        }
    }
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    Dict = result as! [String : AnyObject]

                    let profilePictureURLStr = (Dict["picture"]!["data"]!! as! [String : AnyObject])["url"]
                    let url = NSURL(string: profilePictureURLStr as! String )
                    if let data = NSData(contentsOf: url as! URL){
                        ProfileImg = UIImage(data:data as Data)!
                    }
                    else{
                        print("Error: \(error!.localizedDescription)")
                    }
                    
                    Owner.username = Dict["name"] as! String
                    Owner.fullname = Owner.username
                    Owner.email = Dict["email"] as! String
                    Owner.udid = Dict["id"] as! String
                    Owner.user_type = 1
                    Owner.user_status = 1
                    
                    let parameters = ["username":Owner.username,
                                      "email":Owner.email,
                                      "password":Owner.password,
                                      "name":Owner.fullname,
                                      "user_status":"1",
                                      "user_type":"1",
                                      "avatar":"",
                                      "emergency":Owner.emergency,
                                      "facebookID":Owner.udid,
                                      "device_token":UserToken]
                    let imageData = UIImageJPEGRepresentation(ProfileImg, 0.5)!
                    
                    Alamofire.upload(
                        multipartFormData: { multipartFormData in
                            multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                            for (key, value) in parameters{
                                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                            }
                    }, to: kAPI_FacebookLogin)
                    {result in
                        switch result {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                self.disableUI(disable: false, message: kMsgLoginWithFaceBook)
                                
                                switch response.result {
                                case .success(let value):
                                    print(value)
                                    let jsonObject = JSON(response.result.value!)
                                    Owner.id = jsonObject["user_id"].intValue
                                    Owner.avatar = jsonObject["filename"].stringValue
                                    Owner.updateUserDataWithUserDefault()
                                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                                    self.navigationController?.pushViewController(viewController, animated: true)
                                    break
                                case .failure(let error):
                                    print(error)
                                    self.error_alert(message: kMsgFailedLoginFacebook)
                                    break
                                }
                            }
                        case .failure(let encodingError):
                            print(encodingError)
                        }
                    }
                }
                else{
                    self.disableUI(disable: false, message: kMsgLoginWithFaceBook)
                }
            })
        }
    }

    @IBAction func connectWithEmail(_ sender: Any) {
        Owner.user_type = 2
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "emailLogin") as! EmailVerifyViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func connectWithPhone(_ sender: Any) {
        Owner.user_type = 3
        let udid = UIDevice.current.identifierForVendor!.uuidString
        let parameters = ["udid":udid,
                          "user_type":String(Owner.user_type),
                          "deviceToken":UserToken]
        self.disableUI(disable: true, message: kMsgLoginWithPhone)
        Alamofire.request(kAPI_Login, method: .get, parameters: parameters).responseJSON { response in
            self.disableUI(disable: false, message: kMsgLoginWithPhone)
            
            switch response.result {
            case .success(let value):
                print(value)
                let jsonObject = JSON(response.result.value!)
                let result = jsonObject.rawString()
                if(result == "-1"){                                          //No registered User
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginWithPhoneViewController") as! PhoneVerifyViewController
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                else{                                                       //Success
                    Owner.initUserDataWithJSON(json: jsonObject)
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                break
            case .failure( _):
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginWithPhoneViewController") as! PhoneVerifyViewController
                self.navigationController?.pushViewController(viewController, animated: true)
                break
            }
        }
    }
    
    func disableUI(disable:Bool, message:String){
        var alpha:CGFloat = 1.0
        if(disable){
            alpha = 0.5
            
            loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification?.mode = MBProgressHUDMode.indeterminate
            loadingNotification?.label.text = message
            
            let delayTime = DispatchTime.now() + Double(Int64(30 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                self.disableUI(disable: false, message: message)
            })
        } else {
            self.loadingNotification?.hide(animated: true)
        }
        
        self.btn_email.isEnabled = !disable
        self.btn_email.alpha = alpha
        self.btn_facebook.isEnabled = !disable
        self.btn_facebook.alpha = alpha
        self.btn_phone.isEnabled = !disable
        self.btn_phone.alpha = alpha
        self.ico_facebook.alpha = alpha
        self.ico_email.alpha = alpha
        self.ico_phone.alpha = alpha
    }
    
    //MARK: - Alert
    func error_alert(message: String){
        COMMON.methodForAlert(titleString: kAppName, messageString: message, OKButton: kOkButton, CancelButton: "", viewController: self)
    }
}
