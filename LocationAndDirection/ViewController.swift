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

class ViewController: UIViewController ,CLLocationManagerDelegate{

    @IBOutlet weak var hereLocationView: HereLocationView!
    @IBOutlet weak var purposeLocationView: PurposeLocationView!
    @IBOutlet weak var compassView: CompassView!
    
    @IBOutlet weak var hereLabel: UILabel!
    @IBOutlet weak var hereLat: UILabel!
    @IBOutlet weak var hereLong: UILabel!
    @IBOutlet weak var purposeLabel: UILabel!
    @IBOutlet weak var purposLat: UILabel!
    @IBOutlet weak var purposLong: UILabel!
    @IBOutlet weak var compassImageView: UIImageView!
    @IBOutlet weak var compassLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    //現在地座標
    var hereLocation: CLLocationCoordinate2D?
    var locationManager:CLLocationManager!
    
    //geoDirection()で計算を行うため存在する
    var lat1,lng1,lat2,lng2: CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        purposeSetting()
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
            geoDirection(lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)
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
            
            let label = (res?.administrativeArea)! + (res?.locality)! + (res?.subLocality)!
            self.hereLabel.text = label
        }
    }
    
    //目的地のlabelや住所を手動入力
    private func purposeSetting(){
        let address = "埼玉県春日部市大沼"
        self.purposeLabel.text = address
        let geocorder = CLGeocoder()
        geocorder.geocodeAddressString(address) { (response, error) in
            let res = response?.first
            self.purposLat.text = res?.location?.coordinate.latitude.description
            self.purposLong.text = res?.location?.coordinate.longitude.description
            
            //計算するために保持する
            self.lat2 = res?.location?.coordinate.latitude
            self.lng2 = res?.location?.coordinate.longitude
        }
    }
    
    //方位を計算
    private func geoDirection(lat1: CLLocationDegrees, lng1: CLLocationDegrees, lat2: CLLocationDegrees, lng2: CLLocationDegrees) {
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
        print(dirN0)
    }
}
