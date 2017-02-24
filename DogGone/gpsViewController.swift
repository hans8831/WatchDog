//
//  gpsViewController.swift
//  DogGone
//
//  Created by Love Mob on 12/5/16.
//  Copyright © 2016 Love Mob. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON

class gpsViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btn_menu: UIButton!
    
    var ownerAnt: MKPointAnnotation!
    var ownerCircle: MKCircle!
    var pulseEffect:CustomPulseAnimation? = nil
    var span: MKCoordinateSpan? = nil
    var memberDic = [Int: User]()

    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startTimer()
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
        super.viewDidDisappear(animated)
    }
    
    
    //MARK: - Init Update Location Process
    func initComponents(){
        initSlideMenu()
        
        mapView.delegate = self
        mapView.showsUserLocation = false
        
        updateLocation()
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(gpsViewController.updateLocation), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        timer.invalidate()
    }
    
    func initSlideMenu(){
        if revealViewController() != nil{
            revealViewController().rightViewRevealWidth = 140
            btn_menu.addTarget(revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    @IBAction func btn_back(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    //MARK: - Map Process
    func displayAnnotations() {
        if(ownerCircle != nil){
            self.mapView.remove(ownerCircle)
        }

        if(Owner.refresh){
            if(ownerAnt == nil){
                span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                
                let region = MKCoordinateRegion(center: (Owner.location?.coordinate)!, span: span!)
                self.mapView.setRegion(region, animated: true)
                
                ownerAnt = MKPointAnnotation()
                ownerAnt.coordinate = (Owner.location?.coordinate)!
                ownerAnt.subtitle = String(Owner.id)
                
                self.mapView.addAnnotation(ownerAnt)
            }
            else{
                self.mapView.removeAnnotation(ownerAnt)
                
                ownerAnt = MKPointAnnotation()
                ownerAnt.coordinate = (Owner.location?.coordinate)!
                ownerAnt.subtitle = String(Owner.id)
                
                self.mapView.addAnnotation(ownerAnt)
            }
        }
        else{
            if(ownerAnt == nil){
                span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                
                let region = MKCoordinateRegion(center: (Owner.location?.coordinate)!, span: span!)
                self.mapView.setRegion(region, animated: true)
                
                ownerAnt = MKPointAnnotation()
                ownerAnt.coordinate = (Owner.location?.coordinate)!
                ownerAnt.subtitle = String(Owner.id)
                
                self.mapView.addAnnotation(ownerAnt)
            }
        }

        var existAnt = false
        for annt in self.mapView.annotations{
            let annotation: MKPointAnnotation = annt as! MKPointAnnotation
            existAnt = false
            for (key, value) in self.memberDic{
                if(value.refresh){
                    break
                }
                if(annotation.subtitle == String(key)){
                    existAnt = true
                    annotation.coordinate = (value.location?.coordinate)!
                    break
                }
            }
            if(!existAnt){
                if(annotation.subtitle! != String(Owner.id)){
                    self.mapView.removeAnnotation(annotation)
                }
            }
        }

        ownerCircle = MKCircle(center: (Owner.location?.coordinate)!, radius: CLLocationDistance(Int(Owner.radius * 1000)))
        mapView.add(ownerCircle)
        
        if(memberDic.count != 0){
            for (key, value) in memberDic{
                existAnt = false
                for annt in self.mapView.annotations{
                    let annotation: MKPointAnnotation = annt as! MKPointAnnotation
                    if(annotation.subtitle == String(key)){
                        existAnt = true
                        break;
                    }
                }
                if(!existAnt){
                    let annt:MKPointAnnotation = MKPointAnnotation()
                    annt.coordinate = (value.location?.coordinate)!
                    annt.subtitle = String(value.id)
                    self.mapView.addAnnotation(annt)
                }
            }
        }
        
        ownerAnt.coordinate = (Owner.location?.coordinate)!
    }

    func updateLocation(){
        let parameters = ["user_id":Owner.id,
                          "radius":Owner.radius,
                          "longitude":Owner.location?.coordinate.longitude as Any,
                          "latitude":Owner.location?.coordinate.latitude as Any]
        
        Alamofire.request(kAPI_UserLocations, method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success( _):
                let jsonObject = JSON(response.result.value!)
                var tempMembersDic = [Int : Int]()
                for val in jsonObject.arrayValue {
                    let id = val["user_id"].intValue
                    let location = CLLocation(latitude: CLLocationDegrees(val["latitude"].floatValue), longitude: CLLocationDegrees(val["longitude"].floatValue))
                    let userName = val["username"].stringValue
                    let avatar = val["avatar"].stringValue
                    let user_status = val["user_status"].intValue
                    
                    if(self.memberDic[id] != nil){
                        let ogMember: User = self.memberDic[id]!
                        ogMember.refresh = ((ogMember.avatar != avatar) || (ogMember.user_status != user_status))

                        ogMember.location = location
                        ogMember.username = userName
                        ogMember.avatar = avatar
                        ogMember.user_status = user_status
                        
                    }
                    else{
                        let member: User = User()
                        member.initUserData()
                        member.id = id
                        member.location = location
                        member.username = userName
                        member.avatar = avatar
                        member.user_status = user_status
                        self.memberDic[id] = member
                    }

                    tempMembersDic[id] = id
                }
                for (key, _) in self.memberDic{
                    if(tempMembersDic[key] == nil || tempMembersDic[key]! < 0){
                        self.memberDic.removeValue(forKey: key)
                    }
                }
                tempMembersDic.removeAll()
                
                self.displayAnnotations()
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation){
            return nil
        }

        let identifier = annotation.subtitle
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier!!) as! CustomAnnotationView?
     
        if annotationView == nil{
            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier!)

            if(annotation.subtitle! == String(Owner.id)){
                let ownerProfileImg = IMAGEPROCESSING.makeRoundedImage(image: ProfileImg, radius: 78.4)
                let annoImg = IMAGEPROCESSING.makeMergeImage(bottomImage: OwnerPinImg, topImage: ownerProfileImg)
                annotationView?.image = annoImg

                pulseEffect = CustomPulseAnimation(repeatCount: Float.infinity, radius: 100, position: CGPoint(x: 55, y:51 ), fine: Owner.fine())
                annotationView?.layer.addSublayer(pulseEffect!)
                annotationView?.centerOffset = CGPoint(x: -3.5, y: -52)
                
                changeAnnotationTitle(annotationTitle: Owner.username, annotation: annotation, fine: Owner.fine())
            }
            else{
                let member: User = (memberDic[Int(annotation.subtitle!!)!]! as User)
                let memProfileImg = IMAGEPROCESSING.makeRoundedImage(image: IMAGEPROCESSING.getImageFromURL(imgName: member.avatar), radius: 70)
                let annoImg = IMAGEPROCESSING.makeMergeImageForOtherUsers(bottomImage: MemberPinImg, topImage: memProfileImg)
                annotationView?.image = annoImg
                
                pulseEffect = CustomPulseAnimation(repeatCount: Float.infinity, radius: 100, position: CGPoint(x: 53, y:58 ), fine: member.fine())
                annotationView?.layer.addSublayer(pulseEffect!)
                annotationView?.centerOffset = CGPoint(x: -4.1, y: -55.5)
                
                changeAnnotationTitle(annotationTitle: member.username, annotation: annotation, fine: member.fine())
            }
        }
        else{
            if(annotation.subtitle! == String(Owner.id)){
                if(Owner.refresh){
                    Owner.refresh = false
                    let ownerProfileImg = IMAGEPROCESSING.makeRoundedImage(image: ProfileImg, radius: 78.4)
                    let annoImg = IMAGEPROCESSING.makeMergeImage(bottomImage: OwnerPinImg, topImage: ownerProfileImg)
                    annotationView?.image = annoImg
                    
                    annotationView?.layer.sublayers?.removeAll()
                    pulseEffect = CustomPulseAnimation(repeatCount: Float.infinity, radius: 100, position: CGPoint(x: 55, y:51 ), fine: Owner.fine())
                    annotationView?.layer.addSublayer(pulseEffect!)
                    annotationView?.centerOffset = CGPoint(x: -3.5, y: -52)
                    
                    changeAnnotationTitle(annotationTitle: Owner.username, annotation: annotation, fine: Owner.fine())
                }
            }
            else{
                let member: User = (memberDic[Int(annotation.subtitle!!)!]! as User)
                if(member.refresh){
                    member.refresh = false
                    let member: User = (memberDic[Int(annotation.subtitle!!)!]! as User)
                    let memProfileImg = IMAGEPROCESSING.makeRoundedImage(image: IMAGEPROCESSING.getImageFromURL(imgName: member.avatar), radius: 70)
                    let annoImg = IMAGEPROCESSING.makeMergeImageForOtherUsers(bottomImage: MemberPinImg, topImage: memProfileImg)
                    annotationView?.image = annoImg
                    
                    annotationView?.layer.sublayers?.removeAll()
                    pulseEffect = CustomPulseAnimation(repeatCount: Float.infinity, radius: 100, position: CGPoint(x: 53, y:58 ), fine: member.fine())
                    annotationView?.layer.addSublayer(pulseEffect!)
                    annotationView?.centerOffset = CGPoint(x: -4.1, y: -55.5)
                    
                    changeAnnotationTitle(annotationTitle: member.username, annotation: annotation, fine: member.fine())
                }
            }
            annotationView?.annotation = annotation
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
            circleRenderer.strokeColor = UIColor.red
            circleRenderer.alpha = 0.8
            circleRenderer.lineWidth = 0.5
            return circleRenderer
        }

        return MKOverlayRenderer()
    }
    
    func changeAnnotationTitle(annotationTitle: String, annotation: MKAnnotation, fine: Bool){
        var title = "Help Me"
        if(fine){
            title = annotationTitle
        }
        else{
            title = annotationTitle + ":" + title
        }
        
        (annotation as! MKPointAnnotation).title = title
    }
}

