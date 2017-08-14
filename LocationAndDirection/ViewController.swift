//
//  ViewController.swift
//  LocationAndDirection
//
//  Created by Atsuo Yonehara on 2017/08/14.
//  Copyright © 2017年 Atsuo Yonehara. All rights reserved.
//

import UIKit
import CoreLocation

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
    //現在地座標
    var hereLocation: CLLocationCoordinate2D?
    var locationManager:CLLocationManager!

    
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
        
        print(resultLocation)
        
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
        }
    }
}

