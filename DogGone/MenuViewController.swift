//
//  MenuViewController.swift
//  DogGone
//
//  Created by Love Mob on 12/19/16.
//  Copyright © 2016 Love Mob. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btn_Light(_ sender: Any) {
        revealViewController().rightRevealToggle(animated: true)
        if(Light == false){
            Light = true
        }
        else{
            Light = false
        }
        
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if Light == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    @IBAction func btn_alarm(_ sender: Any) {
        revealViewController().rightRevealToggle(animated: true)
//        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alarmView") as! MainAlarmViewController
//        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func btn_emergency(_ sender: Any) {
        revealViewController().rightRevealToggle(animated: true)
        let phoneNumber  = Owner.emergency
        let phoneString = "tel://\(phoneNumber)"
        let openURL = NSURL(string: phoneString)
        if openURL == nil{
            print("nil")
            return
        }
        let application:UIApplication = UIApplication.shared
        if(application.canOpenURL(openURL as! URL))
        {
            application.open(openURL as! URL, options: [:], completionHandler: nil)
        }
        else{
            print("can't open")
        }
    }
    
    @IBAction func btn_setting(_ sender: Any) {
        revealViewController().rightRevealToggle(animated: true)
        NotificationCenter.default.post(name: NotificationOpenSetting, object: nil)
    }
    
    @IBAction func btn_logout(_ sender: Any) {
        revealViewController().rightRevealToggle(animated: true)
        
        let parameters = ["user_id":Owner.id]
        _ = Alamofire.request(kAPI_Logoff, method: .get, parameters: parameters)
        
        //if(HasLogged){
            //HasLogged = false
            //appDelegate.switchViewControllers()
        //}
        //else{
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as! loginViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        //}
        
        Owner.initUserData()
    }
}
