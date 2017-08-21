//
//  ViewController.swift
//  LocationAndDirection
//
//  Created by Atsuo Yonehara on 2017/08/14.
//  Copyright © 2017年 Atsuo Yonehara. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

class ViewController: UIViewController ,CLLocationManagerDelegate ,UITextFieldDelegate{

    @IBOutlet weak var hereLocationView: HereLocationView!
    @IBOutlet weak var purposeLocationView: PurposeLocationView!
    @IBOutlet weak var compassView: CompassView!
    
    @IBOutlet weak var hereLabel: UILabel!
    @IBOutlet weak var hereLat: UILabel!
    @IBOutlet weak var hereLong: UILabel!
    @IBOutlet weak var purposTextField: UITextField!
    @IBOutlet weak var purposLat: UILabel!
    @IBOutlet weak var purposLong: UILabel!
    @IBOutlet weak var ipTextField: UITextField!
    @IBOutlet weak var compassImageView: UIImageView!
    @IBOutlet weak var compassLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBAction func purposeButtonPushed(_ sender: UIButton) {
        purposeSetting(text: (purposTextField.text?.description)!)
        purposTextField.endEditing(true)
    }
    @IBAction func connectButtonPushed(_ sender: UIButton) {
        connectuion1.connect(address: ipTextField.text!)
        ipTextField.endEditing(true)
    }
    @IBAction func sendButtonPushed(_ sender: UIButton) {
        if (purposTextField.text! as NSString).length > 0 {
            connectuion1.sendCommand(command: purposTextField.text!)
        }
    }
    @IBAction func endButtonPushed(_ sender: UIButton) {
        connectuion1.sendCommand(command: "end")
    }
    //現在地座標
    var hereLocation: CLLocationCoordinate2D?
    var locationManager:CLLocationManager!
    
    //geoDirection()で計算を行うため存在する
    var lat1,lng1,lat2,lng2: CLLocationDegrees!
    
    //Socketのメソッド
    var connectuion1 = Connection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        purposTextField.delegate = self
        getLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //現在地を取る処理
    func getLocation(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
            //方位磁石の処理
            // 何度動いたら更新するか（デフォルトは1度）
            locationManager.headingFilter = kCLHeadingFilterNone
            // デバイスのどの向きを北とするか（デフォルトは画面上部）
            locationManager.headingOrientation = .portrait
            locationManager.startUpdatingHeading()
        }
    }
    
    //現在地取得の際のManager
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    
    //現在地取得の際のManager 毎秒連続して位置情報を取得している
    //基本的にここがずっと呼ばれていることになる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        
        hereLocation = newLocation.coordinate
        guard let resultLocation = hereLocation else {
            print("位置情報取れてません")
            return
        }
        
        let latitude = resultLocation.latitude
        let longtitude = resultLocation.longitude
        
//        let latitude = 35.967622
//        let longtitude = 139.755292
        
        reverseGeocode(latitude: latitude,longitude: longtitude)
        
        hereLat.text = latitude.description
        hereLong.text = longtitude.description
        
        lat1 = latitude
        lng1 = longtitude
        
        if (lat1 != nil) && (lng1 != nil) && (lat2 != nil) && (lng2 != nil) {
            distanceCalculation()
        }
    }
    
    //方位磁石をとる処理
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        print("".appendingFormat("%.2f", newHeading.magneticHeading))
//        print("aaaa")
//        print(newHeading.magneticHeading)
//        print(newHeading.magneticHeading.binade)
        
        if (lat1 != nil) && (lng1 != nil) && (lat2 != nil) && (lng2 != nil) {
            let direction = geoDirection(lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)
            compassRoutetion(direciton: newHeading.magneticHeading)
            arrowRoutetion(direciton: direction + newHeading.magneticHeading)
        }
    }
    
    //緯度経度から住所を決定し、現在地のlabelに貼り付ける
    private func reverseGeocode(latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (response, error) in
            let res = response?.first
//            print("res?.administrativeArea")
//            print(res?.administrativeArea ?? "取れてません")
//            print("res?.locality")
//            print(res?.locality ?? "取れてません")
//            print("res?.subLocality")
//            print(res?.subLocality ?? "取れてません")
//            print((res?.administrativeArea)! + (res?.locality)! + (res?.subLocality)!)
            
            let admin = res?.administrativeArea ?? ""
            let locality = res?.locality ?? ""
            let subLocality = res?.subLocality ?? ""
            
            let label = admin + locality + subLocality
            self.hereLabel.text = label
        }
    }
    
    //目的地のlabelや住所を手動入力
    private func purposeSetting(text: String){
//        //春日部
//        let address = "埼玉県春日部市大沼"
//        //蓮田駅
//        let address = "東京都大田区蒲田４丁目５０−１０"
        //品川水族館
//        let address = "東京都品川区勝島3-2-1"
        let geocorder = CLGeocoder()
        geocorder.geocodeAddressString(text) { (response, error) in
            let res = response?.first
            self.purposLat.text = res?.location?.coordinate.latitude.description
            self.purposLong.text = res?.location?.coordinate.longitude.description
            
            //計算するために保持する
            self.lat2 = res?.location?.coordinate.latitude
            self.lng2 = res?.location?.coordinate.longitude
        }
    }
    
    //方位を計算
    private func geoDirection(lat1: CLLocationDegrees, lng1: CLLocationDegrees, lat2: CLLocationDegrees, lng2: CLLocationDegrees) -> Double {
        // 緯度経度 lat1, lng1 の点を出発として、緯度経度 lat2, lng2 への方位
        // 北を０度で右回りの角度０～３６０度
        let Y = cos(lng2 * Double.pi / 180) * sin(lat2 * Double.pi / 180 - lat1 * Double.pi / 180);
        let X = cos(lng1 * Double.pi / 180) * sin(lng2 * Double.pi / 180) - sin(lng1 * Double.pi / 180) * cos(lng2 * Double.pi / 180) * cos(lat2 * Double.pi / 180 - lat1 * Double.pi / 180);
        var dirE0 = 180 * atan2(Y, X) / Double.pi; // 東向きが０度の方向
        if (dirE0 < 0) {
            dirE0 = dirE0 + 360; //0～360 にする。
        }
        //let dirN0 = (dirE0 + 90) % 360; //(dirE0+90)÷360の余りを出力 北向きが０度の方向
        let dirN0 = (dirE0 + 90).truncatingRemainder(dividingBy: 360)
        return dirN0
    }
    
    //起動時に矢印が回転する
    private func arrowRoutetion(direciton: Double){
        var d = direciton
        if d > 360 {
            d = d - 360
        }
        
        //iが回転させたい角度
        let i = CGFloat(-d)
        let angle = i * CGFloat.pi / 180
        arrowImageView.transform = CGAffineTransform(rotationAngle: angle)
    }
    
    //compassが回転する
    private func compassRoutetion(direciton: Double){
        var d = direciton
        if d > 360 {
            d = d - 360
        }
        
        //iが回転させたい角度
        let i = CGFloat(-d)
        let angle = i * CGFloat.pi / 180
        compassImageView.transform = CGAffineTransform(rotationAngle: angle)
        
        var directionWord = ""
        var directionDouble = d.description
       
        if directionDouble.contains(".") {
            directionDouble = d.description.components(separatedBy: ".").first!
        }
        
        if (d >= 315) || (d < 45) {
            directionWord = "北"
        }else if (d >= 45) && (d < 135) {
            directionWord = "東"
        }else if (d >= 135) && (d < 225) {
            directionWord = "南"
        }else if (d >= 225) && (d < 315) {
            directionWord = "西"
        }
        
        self.compassLabel.text = directionWord + ":" + directionDouble
    }
    
    private func distanceCalculation() {
        let here = CLLocation(latitude: lat1, longitude: lng1)
        let purpose = CLLocation(latitude: lat2, longitude: lng2)
        let distance = purpose.distance(from: here)
        let k = Int(distance / 1000)
        let m = Double(distance) - Double(k * 1000)
        var mStr = m.description
        if mStr.contains(".") {
            mStr = mStr.components(separatedBy: ".").first!
        }
        distanceLabel.text = k.description + "Km" + mStr + "m"
    }
}
