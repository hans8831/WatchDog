//
//  AppDelegate.swift
//  DogGone
//
//  Created by Love Mob on 12/5/16.
//  Copyright © 2016 Love Mob. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import UserNotifications
import Foundation
import AudioToolbox
import AVFoundation
import Alamofire
import UserNotifications

protocol AlarmApplicationDelegate
{
    func playAlarmSound(_ soundName: String)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate, AlarmApplicationDelegate, PushNotificationDelegate{
    var window: UIWindow?
    var audioPlayer: AVAudioPlayer?
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //push notification
        //let center = UNUserNotificationCenter.current()
        //center.delegate = self
        //center.requestAuthorization(options: [.badge, .alert, .sound]){(granted, error) in
        //}
        //application.registerForRemoteNotifications()
        
        PushNotificationManager.push().delegate = self
        PushNotificationManager.push().handlePushReceived(launchOptions)
        PushNotificationManager.push().sendAppOpen()
        PushNotificationManager.push().registerForPushNotifications()
        
        initAlarm()
        
        Owner.initUserData()
        Owner.initUserDataWithUserDefault()
        
        if(Owner.id > 0){
            //HasLogged = true
            //defaultUser()                             //No Need to Use This Function.
        }

        initAppBadge()

        return true
        //return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        //let parameters = ["user_id":owner.id]
        //_ = Alamofire.request(kAPI_Logoff, method: .get, parameters: parameters)
    }
    
    func switchViewControllers(){
        //switch root view controllers
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "startNav")
        
        self.window?.rootViewController = rootViewController
    }
    
    func defaultUser(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
        self.window?.rootViewController = initialViewController
    }
    
    func initAlarm(){
        alarmScheduler.setupNotificationSettings()
        window?.tintColor = UIColor.red
    }
    
    func initAppBadge(){
        if(UIApplication.shared.applicationIconBadgeNumber != 0){
            HasNewNotification = true
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            app,
            open: url as URL!,
            sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
            annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool{
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url as URL!,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        initAppBadge()
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UserToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        PushNotificationManager.push().handlePushRegistration(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData) // indicates that new data was successfully fetched
        PushNotificationManager.push().handlePushReceived(userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationManager.push().handlePushRegistrationFailure(error)
    }
    
    func onPushAccepted(_ pushManager: PushNotificationManager!, withNotification pushNotification: [AnyHashable : Any]!, onStart: Bool) {
        NotificationCenter.default.post(name: NotificationName, object: nil)
    }
    
    //MARK - alarm
    func backRootViewController(){
        self.window?.rootViewController = rootViewController
        rootViewController = nil
    }
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        rootViewController = self.window?.rootViewController
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "alarmNav")
        self.window?.rootViewController = initialViewController
        
        //if app is in foreground, show a alert
        let storageController = UIAlertController(title: "Alarm", message: nil, preferredStyle: .alert)
        //todo, snooze
        var isSnooze: Bool = false
        var soundName: String = ""
        var index: Int = -1
        if let userInfo = notification.userInfo {
            isSnooze = userInfo["snooze"] as! Bool
            soundName = userInfo["soundName"] as! String
            index = userInfo["index"] as! Int
        }
        
        playAlarmSound(soundName)
        
        if isSnooze  == true
        {
            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let now = Date()
            //snooze 9 minutes later
            let snoozeTime = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.minute, value: 9, to: now, options:.matchStrictly)!
            
            let snoozeOption = UIAlertAction(title: "Snooze", style: .default) {
                (action:UIAlertAction)->Void in self.audioPlayer?.stop()
                
                self.alarmScheduler.setNotificationWithDate(snoozeTime, onWeekdaysForNotify: [Int](), snooze: true, soundName: soundName, index: index)
            }
            storageController.addAction(snoozeOption)
        }
        let stopOption = UIAlertAction(title: "OK", style: .default) {
            (action:UIAlertAction)->Void in self.audioPlayer?.stop()
            Alarms.sharedInstance.setEnabled(false, AtIndex: index)
            let vc = self.window?.rootViewController! as! UINavigationController
            let cells = (vc.topViewController as! MainAlarmViewController).tableView.visibleCells
            for cell in cells
            {
                if cell.tag == index{
                    let sw = cell.accessoryView as! UISwitch
                    sw.setOn(false, animated: false)
                }
            }
        }
        
        storageController.addAction(stopOption)
        window?.rootViewController!.present(storageController, animated: true, completion: nil)
    }
    //notification handler, snooze
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void)
    {
        if identifier == "mySnooze"
        {
            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let now = Date()
            let snoozeTime = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.minute, value: 9, to: now, options:.matchStrictly)!
            var soundName: String = ""
            var index: Int = -1
            if let userInfo = notification.userInfo {
                soundName = userInfo["soundName"] as! String
                index = userInfo["index"] as! Int
                self.alarmScheduler.setNotificationWithDate(snoozeTime, onWeekdaysForNotify: [Int](), snooze: true, soundName: soundName, index: index)
            }
        }
        completionHandler()
    }
    //print out all registed NSNotification for debug
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        print(notificationSettings.types.rawValue)
    }
    
    //AlarmApplicationDelegate protocol
    func playAlarmSound(_ soundName: String) {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let url = URL(
            fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "mp3")!)
        
        var error: NSError?
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("audioPlayer error \(err.localizedDescription)")
        } else {
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
        }
        //negative number means loop infinity
        audioPlayer!.numberOfLoops = -1
        audioPlayer!.play()
    }

    //todo,vibration infinity
    func vibrationCallback(_ id:SystemSoundID, _ callback:UnsafeMutableRawPointer) -> Void
    {
        print("callback", terminator: "")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully
        flag: Bool) {
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer,
                                        error: Error?) {
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
    }
}

