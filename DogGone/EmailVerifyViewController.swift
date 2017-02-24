//
//  EmailVerifyViewController.swift
//  DogGone
//
//  Created by Love Mob on 12/7/16.
//  Copyright © 2016 Love Mob. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class EmailVerifyViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var view_Login: UIView!
    @IBOutlet weak var txt_UserName: UITextField!
    @IBOutlet weak var txt_Password: UITextField!
    @IBOutlet weak var btn_Login: UIButton!
    @IBOutlet weak var btn_ForgotPass: UIButton!
    @IBOutlet weak var btn_SignUp: UIButton!
    @IBOutlet weak var ico_User: UIImageView!
    @IBOutlet weak var ico_Pass: UIImageView!
    
    @IBOutlet var mainView: UIView!
    var loadingNotification:MBProgressHUD? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.txt_UserName.resignFirstResponder()
        self.txt_Password.resignFirstResponder()
    }
    
    func initComponents(){
        view_Login.layer.borderWidth = 0.3
        view_Login.layer.cornerRadius = 5.0
        view_Login.layer.borderColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.6).cgColor
        
        btn_Login.layer.borderWidth = 0.3
        btn_Login.layer.cornerRadius = 5.0
        btn_Login.layer.borderColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.6).cgColor
        
        btn_SignUp.layer.borderWidth = 0.3
        btn_SignUp.layer.cornerRadius = 5.0
        btn_SignUp.layer.borderColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.6).cgColor
        
        btn_ForgotPass.isEnabled = false
        self.btn_ForgotPass.alpha = 0.3
   }

    @IBAction func btn_back(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Login
    @IBAction func btn_login(_ sender: Any) {
        self.txt_UserName.resignFirstResponder()
        self.txt_Password.resignFirstResponder()
        
        if (txt_UserName.text == "User Name" || txt_UserName.text == ""){
            error_alert(message: kEnterUserName)
        }else if (txt_Password.text == "Password" || txt_Password.text == ""){
            error_alert(message: kEnterPassword)
            
        }else{
            disableUI(disable: true)
            login()
        }
    }

    func login(){
        let parameters = ["username":txt_UserName.text!,
                          "password":txt_Password.text!,
                          "user_type":"2",
                          "device_token":UserToken]

        print(parameters)
        print(kAPI_Login)
        Alamofire.request(kAPI_Login, method: .get, parameters: parameters).responseJSON { response in
            self.disableUI(disable: false)
            switch response.result {
            case .success(let value):
                print(value)
                let jsonObject = JSON(response.result.value!)
                let result = jsonObject.rawString()
                if(result == "1"){                                          //Wrong Password
                    self.error_alert(message: kWrongPass)
                    self.btn_ForgotPass.isEnabled = true
                    self.btn_ForgotPass.alpha = 1
                }
                else if(result == "2"){                                     //No registered User
                    self.error_alert(message: kNotExist)
                    self.btn_ForgotPass.isEnabled = false
                    self.btn_ForgotPass.alpha = 0.3
                }
                else{                                                       //Success
                    Owner.initUserDataWithJSON(json: jsonObject)
                    Owner.updateUserDataWithUserDefault()
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                break
            case .failure(let error):
                self.btn_ForgotPass.isEnabled = false
                self.btn_ForgotPass.alpha = 0.3
                print(error)
                self.error_alert(message: kLoginRequest)
                break
            }
        }
    }
    
    //MARK: - Forget Password
    @IBAction func btn_forgetPass(_ sender: Any) {
        Owner.username = txt_UserName.text!
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "resetPass") as! ResetViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK: - Sign up
    @IBAction func btn_signUp(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "emailSignUp") as! SignUpViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    //MARK: - Move UIView When Keyboard appear
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    func disableUI(disable:Bool){
        var alpha:CGFloat = 1.0
        if(disable){
            alpha = 0.5
            
            loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification?.mode = MBProgressHUDMode.indeterminate
            loadingNotification?.label.text = "Verifying..."
        } else {
            self.loadingNotification?.hide(animated: true)
        }
        
        self.txt_UserName.isEnabled = !disable
        self.txt_UserName.alpha = alpha
        self.txt_Password.isEnabled = !disable
        self.txt_Password.alpha = alpha
        self.btn_Login.isEnabled = !disable
        self.btn_Login.alpha = alpha
        self.btn_SignUp.isEnabled = !disable
        self.btn_SignUp.alpha = alpha
//        self.btn_ForgotPass.isEnabled = !disable
//        self.btn_ForgotPass.alpha = alpha / 2
        self.ico_User.alpha = alpha
        self.ico_Pass.alpha = alpha
    }
    
    //MARK: - Alert
    func error_alert(message: String){
        COMMON.methodForAlert(titleString: kAppName, messageString: message, OKButton: kOkButton, CancelButton: "", viewController: self)
    }
}
