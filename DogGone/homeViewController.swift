//
//  homeViewController.swift
//  DogGone
//
//  Created by Love Mob on 12/5/16.
//  Copyright © 2016 Love Mob. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit
import CoreLocation
import Alamofire

class homeViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var btn_menu: UIButton!
    @IBOutlet weak var profile_img: UIImageView!
    @IBOutlet weak var lbl_currentTime: UILabel!
    @IBOutlet weak var lbl_currentAddress: UILabel!
    @IBOutlet weak var lbl_userName: UILabel!
    
    var timer = Timer()
    var locationManager: CLLocationManager!
    var lastLocation:CLLocation? = nil

    let formatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Owner.username.isEmpty){
            Owner.username = "User_" + String(Owner.id)
        }
        
        initSlideMenu()
        if ( CLLocationManager.locationServicesEnabled()){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
            locationManager.startUpdatingLocation()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(initViewForPushNotification), name: NotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openSetting), name: NotificationOpenSetting, object: nil)
        if(HasNewNotification){
            HasNewNotification = false
            NotificationCenter.default.post(name: NotificationName, object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initUserProfileImg()
        initUserFullName()
        startTimer()
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initComponents()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
        super.viewDidDisappear(animated)
    }
    
    //MARK: - Push Notification Accepted
    func initViewForPushNotification(){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "gpsView") as! gpsViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK: - Init Components
    func initComponents(){
        initUserProfileImg()
        initUserFullName()
        tick()
    }
    
    func initUserFullName(){
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: Owner.fullname, attributes: underlineAttribute)
        lbl_userName.attributedText = underlineAttributedString
    }
    
    func initUserProfileImg(){
        let img = IMAGEPROCESSING.makeRoundedImage(image: ProfileImg, radius: Float(self.profile_img.frame.height/2))
        
        self.profile_img.image = img
        self.profile_img.layer.borderWidth = 1
        self.profile_img.layer.masksToBounds = false
        self.profile_img.layer.borderColor = UIColor.white.cgColor
        self.profile_img.layer.cornerRadius = self.profile_img.frame.height/2
        self.profile_img.clipsToBounds = true
    }
    
    func initSlideMenu(){
        if revealViewController() != nil{
            revealViewController().rightViewRevealWidth = 140
            btn_menu.addTarget(revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(homeViewController.tick), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        timer.invalidate()
    }

    //MARK: - Setting current time & address
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations.last! as CLLocation
        if( location == Owner.location){
            return
        }
        Owner.location = location
        setAddress()
        updateLocation()
    }
    
    func updateLocation(){
        let parameters = ["user_id":Owner.id,
                          "user_status":Owner.user_status,
                          "radius":Owner.radius,
                          "longitude":Owner.location?.coordinate.longitude as Any,
                          "latitude":Owner.location?.coordinate.latitude as Any]
        
        _ = Alamofire.request(kAPI_UpdateLocation, method: .get, parameters: parameters)
    }
    
    func setAddress(){
        CLGeocoder().reverseGeocodeLocation(Owner.location!, completionHandler: { (placemarks, error) -> Void in
            if(error != nil){
                return
            }
            var placeMark: CLPlacemark!
            var addressStr = ""
            
            placeMark = CLPlacemark(placemark: (placemarks?[0])! as CLPlacemark)
            if( placeMark == nil){
                return
            }
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                addressStr = locationName as String
            }
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                addressStr = addressStr + ", " + (city as String)
            }
            if(!addressStr.isEmpty){
                self.lbl_currentAddress.text = addressStr
            }
        })
    }
    
    func tick(){
        let date = Date()
        formatter.dateFormat = "EEEE d MMMM yyyy - hh:mm a"
        lbl_currentTime.text = (formatter.string(from: date)).uppercased()
    }
    
    //MARK: - Touch events
    @IBAction func findDog(_ sender: Any) {
        Owner.user_status = 2 //Help Me
        let parameters = ["user_id":Owner.id,
                          "user_status":String(Owner.user_status),
                          "user_name":Owner.username,
                          "radius":Owner.radius,
                          "longitude":Owner.location?.coordinate.longitude as Any,
                          "latitude":Owner.location?.coordinate.latitude as Any]
        
        
        _ = Alamofire.request(kAPI_PushNotification, method: .get, parameters: parameters)
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "gpsView") as! gpsViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func ok(_ sender: Any) {
        Owner.user_status = 1 //Fine
        updateLocation()
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "gpsView") as! gpsViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func bellRing(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alarmNav")
        self.present(viewController!, animated: true, completion: nil)
    }
    
    @IBAction func emergencyCall(_ sender: Any) {
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

    @IBAction func turnLight(_ sender: Any) {
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
    
    @IBAction func showProfile(_ sender: Any) {
        openSetting()
    }
    
    func openSetting(){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "profile") as! profileViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
