//
//  PhoneVerifyViewController.swift
//  DogGone
//
//  Created by Love Mob on 12/7/16.
//  Copyright © 2016 Love Mob. All rights reserved.
//

import UIKit
import SinchVerification
import MBProgressHUD
import Alamofire
import SwiftyJSON

class PhoneVerifyViewController: UIViewController {
    
    var verification:Verification!
    var applicationKey = "1f21b966-fdf8-4ce7-aee9-25a4af5581c1"
    var loadingNotification: MBProgressHUD? = nil
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var calloutButton: UIButton!
    @IBOutlet weak var smsButton: UIButton!
    @IBOutlet weak var status: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
    }

    override func viewWillAppear(_ animated: Bool) {
        phoneNumber.becomeFirstResponder()
        disableUI(disable: false)
    }
    
    func initComponents(){
        phoneNumber.layer.borderWidth = 0.3
        phoneNumber.layer.cornerRadius = 5.0
        phoneNumber.layer.borderColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.6).cgColor
        
        calloutButton.layer.borderWidth = 0.3
        calloutButton.layer.cornerRadius = 5.0
        calloutButton.layer.borderColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.6).cgColor
        
        smsButton.layer.borderWidth = 0.3
        smsButton.layer.cornerRadius = 5.0
        smsButton.layer.borderColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.6).cgColor
    }
    
    @IBAction func btn_back(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "enterPin"){
            let enterCodeVC = segue.destination as! SmsVerifyViewController
            enterCodeVC.verification = self.verification
        }
    }

    @IBAction func callout(_ sender: Any) {
        disableUI(disable: true)
        verification = CalloutVerification(applicationKey, phoneNumber: phoneNumber.text!)
        
        verification.initiate { (initiationResult, error) -> Void in
            if(initiationResult.success){
                
                let udid = UIDevice.current.identifierForVendor!.uuidString
                let parameters = ["udid":udid,
                                  "user_type":"3"]
                
                Alamofire.request(kAPI_Registration, method: .get, parameters: parameters).responseString{ response in

                    self.status.text = "Verified"
                    self.disableUI(disable: false)
                    
                    switch response.result{
                    case .success(_):
                        Owner.id = Int(response.result.value!)!
                        Owner.username = "User" + String(Owner.id)
                        Owner.user_type = 3
                        Owner.updateUserDataWithUserDefault()
                        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                        self.navigationController?.pushViewController(viewController, animated: true)
                        
                        break;
                    case .failure(let error):
                        print (error)
                        self.error_alert(message: kMsgFailedPhoneVerify)
                        break;
                    }
                }
            }
            else{
                self.status.text = error?.localizedDescription
            }
        }
    }
    
    @IBAction func sms(_ sender: Any) {
        disableUI(disable: true)
        verification = SMSVerification(applicationKey, phoneNumber: phoneNumber.text!)
        verification.initiate { (initiationResult, error) in
            self.disableUI(disable: false)
            if(initiationResult.success){
                self.performSegue(withIdentifier: "enterPin", sender: sender)
            }else{
                self.status.text = error?.localizedDescription
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    func disableUI(disable:Bool){
        var alpha:CGFloat = 1.0
        if(disable){
            alpha = 0.5
            phoneNumber.resignFirstResponder()
            
            loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification?.mode = MBProgressHUDMode.indeterminate
            loadingNotification?.label.text = "Verifying..."
            
            self.status.text = ""
            let delayTime = DispatchTime.now() + Double(Int64(30 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                self.disableUI(disable: false)
            })
        } else {
            self.phoneNumber.becomeFirstResponder()
            self.loadingNotification?.hide(animated: true)
        }
        
        self.phoneNumber.isEnabled = !disable
        self.smsButton.isEnabled = !disable
        
        self.calloutButton.isEnabled = !disable
        self.calloutButton.alpha = alpha
        self.smsButton.alpha = alpha
    }
    
    //MARK: - Alert
    func error_alert(message: String){
        COMMON.methodForAlert(titleString: kAppName, messageString: message, OKButton: kOkButton, CancelButton: "", viewController: self)
    }
}
