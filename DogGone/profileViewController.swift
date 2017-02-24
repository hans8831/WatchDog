//
//  profileViewController.swift
//  DogGone
//
//  Created by Love Mob on 12/19/16.
//  Copyright © 2016 Love Mob. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class profileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var btn_menu: UIButton!
    @IBOutlet weak var lbl_userName: UILabel!
    @IBOutlet weak var profile_img: UIImageView!
    
    @IBOutlet weak var txt_fullName: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_callNumber: UITextField!
    @IBOutlet weak var txt_radius: UITextField!
    
    @IBOutlet weak var insertView: UIView!
    
    var bScreenUp = 0
    var tmpTextFeild: UITextField! = nil
    let imagePicker = UIImagePickerController()
    var userImg = ProfileImg
    var loadingNotification: MBProgressHUD? = nil
    var changeImage = false
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        initProfileImgComponent()
    }
    
    func initComponents(){
        if revealViewController() != nil{
            revealViewController().rightViewRevealWidth = 140
            btn_menu.addTarget(revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: Owner.fullname, attributes: underlineAttribute)
        lbl_userName.attributedText = underlineAttributedString

        if(Owner.emergency.isEmpty){
            Owner.emergency = "112"
        }
        txt_fullName.text = Owner.fullname
        txt_callNumber.text = Owner.emergency
        txt_radius.text = String(Owner.radius)
        txt_email.text = Owner.email
        
        txt_fullName.tag = 100
        txt_callNumber.tag = 101
        txt_radius.tag = 102
        txt_email.tag = 103
    }
    
    func initProfileImgComponent(){
        let img = IMAGEPROCESSING.makeRoundedImage(image: userImg, radius: Float(self.profile_img.frame.height/2))
        
        self.profile_img.image = img
        self.profile_img.layer.borderWidth = 1
        self.profile_img.layer.masksToBounds = false
        self.profile_img.layer.borderColor = UIColor.white.cgColor
        self.profile_img.layer.cornerRadius = self.profile_img.frame.height/2
        self.profile_img.clipsToBounds = true
    }

    func saveSetting(){
        if (tmpTextFeild != nil){
            tmpTextFeild.resignFirstResponder()
            hideKeyboard()
        }
    }
    
    @IBAction func btn_back(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - profile image
    @IBAction func changeProfileImg(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        changeImage = true
        userImg = info[UIImagePickerControllerOriginalImage] as! UIImage
        initProfileImgComponent()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func UpdateProfile(_ sender: Any) {
        if (txt_email.text == "Email" || txt_email.text == ""){
            error_alert(message: kEnterEmail)
        }else if (txt_fullName.text == "User Name" || txt_fullName.text == ""){
            error_alert(message: kEnterUserName)
        }else if (txt_callNumber.text == "Emergency Call Number (112)" || txt_callNumber.text == ""){
            error_alert(message: kEnterMobile)
        }else if (!COMMON.methodIsValidEmailAddress(email: txt_email.text!)){
            error_alert(message: kEnterValidEmail)
        }else if (txt_radius.text == "Radius" || txt_radius.text == ""){
            error_alert(message: kEnterRadius)
        }else if(!COMMON.methodIsValidFloat(val: txt_radius.text!)){
            error_alert(message: kEnterValidRadius)
        }else{
            disableUI(disable: true, message: kMsgUpdateProfile)
            UpdateProfileProcess()
        }
    }
    
    func UpdateProfileProcess(){
        let parameters = ["user_id":String(Owner.id),
                          "fullname":txt_fullName.text!,
                          "emergency":txt_callNumber.text!,
                          "radius":txt_radius.text!,
                          "email":txt_email.text!,
                          "imageChange":changeImage ? "1" : "0"]
        let imageData = UIImageJPEGRepresentation(userImg, 0.5)!
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                for (key, value) in parameters{
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
        }, to: kAPI_UpdateProfile)
        {result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    self.disableUI(disable: false, message: kMsgUpdateProfile)
                    
                    switch response.result {
                    case .success(_):
                        let jsonObject = JSON(response.result.value!)
                        
                        Owner.fullname = self.txt_fullName.text!
                        Owner.emergency = self.txt_callNumber.text!
                        Owner.radius = Float(self.txt_radius.text!)!
                        Owner.email = self.txt_email.text!
                        
                        if(self.changeImage){
                            self.changeImage = false
                            Owner.avatar = jsonObject["avatar"].stringValue
                            ProfileImg = self.userImg
                        }
                        Owner.refresh = true
                        Owner.updateUserDataWithUserDefault()
                        _ = self.navigationController?.popViewController(animated: true)
                        break
                    case .failure(_):
                        self.error_alert(message: kMsgFailedToUpdateProfile)
                        break
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    //MARK: - Move UIView When Keyboard appear
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tmpTextFeild = textField
        
        if (bScreenUp == 0 && textField.tag > 99){
            bScreenUp = 1
            animateViewMoving(up: true, moveValue: 185)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tmpTextFeild = nil
        hideKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func hideKeyboard(){
        if (bScreenUp == 1){ //Screen Up
            bScreenUp = 0
            animateViewMoving(up: false, moveValue: 185)
        }
        
        if tmpTextFeild != nil{
            UIView.animate(withDuration: 0.5, animations: {
                self.tmpTextFeild.resignFirstResponder()
            })
        }
    }

    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.5
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.insertView.frame = self.insertView.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
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
                self.disableUI(disable: false, message: kMsgUpdateProfile)
            })
        } else {
            self.loadingNotification?.hide(animated: true)
        }
        
        self.txt_callNumber.isEnabled = !disable
        self.txt_callNumber.alpha = alpha
        self.txt_radius.isEnabled = !disable
        self.txt_radius.alpha = alpha
        self.profile_img.isUserInteractionEnabled = !disable
        self.profile_img.alpha = alpha
    }
    
    //MARK: - Alert
    func error_alert(message: String){
        COMMON.methodForAlert(titleString: kAppName, messageString: message, OKButton: kOkButton, CancelButton: "", viewController: self)
    }
}
