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
    
    //現在地座標
    var hereLocation: CLLocationCoordinate2D?
    var locationManager:CLLocationManager!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        
        print(resultLocation)
        
    }
}

