//
//  AllMacros.swift
//  
//
//  Created by Love Mob on 12/8/16.
//  Copyright © 2016 Love Mob. All rights reserved.
//

// To do 

//•	Who can view my location – public – friends – nobody
//•	Who can send me direct message – public – friends – nobody
//•	Clear conversation - none – 3 days- 5 days - 1 week – clear conversation
//•	Phone book search – allow people to find me – ON - OFF
//•	Change location (AUTOMATIC) When the user select this it will automatically update there location by gps, Country and city under users name on home page
//
//•	Host history  - clear host history
//•	Notification
//•	Block contact
//

import Foundation
import UIKit

let NotificationName = NSNotification.Name("PushNotificationAccepted")
let NotificationOpenSetting = NSNotification.Name("OpenSetting")
var Dict : [String : AnyObject]!
let IMAGEPROCESSING = ImageProcessing()
var ProfileImg:UIImage = #imageLiteral(resourceName: "male.jpeg")
let OwnerPinImg:UIImage = #imageLiteral(resourceName: "point.png")
let MemberPinImg:UIImage = #imageLiteral(resourceName: "otherPoint.png")
var UserToken = ""

var rootViewController: UIViewController? = nil

var HasLogged = false
var HasNewNotification = false

var Light = false

let appDelegate = UIApplication.shared.delegate as! AppDelegate

let COMMON = Common()
let Owner = User()
let Prefs = UserDefaults.standard

//Alert Message
let kAppName = "Dog-Gone"
let kWrongPass = "Your password is incorrect. \nIf you don't remember your password, reset it now."
let kNotExist = "Your account is not exist. \nPlease sign up for Doggone."
let kLoginRequest = "Sorry, unable to login for now. \nPlease try again later."
let kChangePassFailed = "Sorry, unable to change the password for now. \nPlease try again later."
let kChangePassSuccess = "Your password changed successfully."

let kEnterUserName = "Please enter user name."
let kEnterPassword = "Please enter password."
let kEnterEmail = "Please enter email address."
let kEnterName = "Please enter your name."
let kEnterMobile = "Please enter your phone number."
let kEnterValidEmail =  "Please enter valid email address."
let kConfirmPassword = "Please confirm your password."
let kEnterRadius = "Please enter radius."
let kEnterValidRadius =  "Please enter valid radius."
let kOkButton = "Ok"

let kDuplicateUserName = "Duplicated User Name. Please use another User Name."
let kViewForgotPassword = "ForgotPassword"
let kNetworksNotAvailvle = "Please check your internet connection."
let kConfirmEmail = "Please confirm email address."
let kEnterCorrectPassword = "Please enter your password. It should be minimum 8 characters."
let kEnterUsernameOrPassword = "Please enter your user name or password."
let kInvalidNO = "Please provide valid No."
let kLoginFailed = "Login Failed."
let kSignUpRequest = "We are unable to Sign up. Please try later..."
let kEmailNotMatch = "Email does not match."
let kMandatory = "Please fill both fields."
let kResetPassword = "Password reset succesfully. Email sent to your registered email address."
let kimageMotive = "keyMotiveImage"

//APIs
let kAPI_Domain = "https://dog.highpriority-it.com/"
let kAPI_Login = kAPI_Domain + "login.php"
let kAPI_Registration = kAPI_Domain + "user_create.php"
let kAPI_Logoff = kAPI_Domain + "logoff.php"
let kAPI_ForgotPassword = kAPI_Domain + "user_update.php"
let kAPI_FacebookLogin = kAPI_Domain + "login_facebook.php"
let kAPI_CheckUser = kAPI_Domain + "check_user.php"

let kAPI_UpdateProfile = kAPI_Domain + "update_profile.php"
let kAPI_UpdateLocation = kAPI_Domain + "update_location.php"
let kAPI_PushNotification = kAPI_Domain + "pushNotification.php"
let kAPI_UserLocations = kAPI_Domain + "get_userLocations.php"

let kAPI_URL = kAPI_Domain + "images/"

//Stored User Data
let kPrefsUserID = "UserID"
let kPrefsUserName = "UserName"
let kPrefsPassword = "Password"
let kPrefsFullName = "FullName"
let kPrefsRadius = "Radius"
let kPrefsEmergency = "Emergency"
let kPrefsAvatar = "Avatar"
let kPrefsEmail = "Email"

//Message for Error Alert
let kMsgVerify = "Verifying..."
let kMsgCheckUserName = "Checking User Name..."
let kMsgUpdateProfile = "Updating Profile..."
let kMsgLoginWithFaceBook = "Connectting with Facebook..."
let kMsgLoginWithPhone = "Connectting with you Phone..."
let kMsgResetPass = "Resetting Password..."
let kMsgFailedLoginFacebook = "Sorry, unable to login with your facebook account for now. Please try again later."
let kMsgFailedSignUp = "Sorry, unable to sign up for now. Please try again later."
let kMsgFailedToUpdateProfile = "Sorry, unable to update your profile for now. \nPlease try again later."
let kMsgFailedPhoneVerify = "Sorry, unable to verify with you phone for now. \nPlease try again later."
let kMsgFailedSmsVerify = "Sorry, unable to verify with sms. \nPlease try again later."
