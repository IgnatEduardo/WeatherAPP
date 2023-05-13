//
//  ViewController.swift
//  WeatherProject

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet var table: UITableView!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 227/255.0, green: 244/255.0, blue: 254/255.0, alpha: 1.0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil  {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeather()
        }
    }
    
    func requestWeather() {
        
        guard let currentLocation = currentLocation else {
            return
        }

        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        print("\(long), \(lat)")
        
        //AccuWeather API key
        let apiKey = "SdmUfjJec1wP7ggXAX1J0u4rG6nbfaxz"
        
        //API Requests using URLSession
        
        //Get location key using geoposition search API
        let geoUrl = "https://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(apiKey)&q=\(lat),\(long)"
        URLSession.shared.dataTask(with: URL(string: geoUrl)!) { (data, response, error) in
            guard let data = data, error == nil else {
                print("something went wrong")
                return
            }
            var locationKey: String?
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                //location key
                if let dict = json as? [String: Any], let key = dict["Key"] as? String {
                    locationKey = key
                }
                
                
            } catch {
                print("Error decoding location data: \(error)")
            }
            
            guard let locKey = locationKey else {
                print("could not get location key")
                return
            }
            
            print(locKey)
            
            
        }.resume()
    }

}
