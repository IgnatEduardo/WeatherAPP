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
            
            let hourlyUrl = "https://dataservice.accuweather.com/forecasts/v1/hourly/12hour/\(locKey)?apikey=\(apiKey)&metric=true"
            URLSession.shared.dataTask(with: URL(string: hourlyUrl)!) { (data, response, error) in
                guard let data = data, error == nil else {
                    print("something went wrong")
                    return
                }
                var hourly: [HourlyForecast]?
                do {
                    hourly = try JSONDecoder().decode([HourlyForecast].self, from: data)
                } catch {
                    print("error: \(error)")
                }
                
                guard let hourlyForecasts = hourly else {
                    print("could not get hourly forecasts")
                    return
                }
                
                print(hourlyForecasts[0])
                
            }.resume()
        }.resume()
    }

}

//Codable struct object to store the data from the requests with JSONDecoder

struct HourlyForecast: Codable {
    let dateTime: String
    let epochDateTime: Int
    let weatherIcon: Int
    let iconPhrase: String
    let hasPrecipitation: Bool
    let precipitationType: String?
    let precipitationIntensity: String?
    let isDaylight: Bool
    let temperature: Temperature
    let precipitationProbability: Int
    let mobileLink: String
    let link: String
    
    enum CodingKeys: String, CodingKey {
        case dateTime = "DateTime"
        case epochDateTime = "EpochDateTime"
        case weatherIcon = "WeatherIcon"
        case iconPhrase = "IconPhrase"
        case hasPrecipitation = "HasPrecipitation"
        case precipitationType = "PrecipitationType"
        case precipitationIntensity = "PrecipitationIntensity"
        case isDaylight = "IsDaylight"
        case temperature = "Temperature"
        case precipitationProbability = "PrecipitationProbability"
        case mobileLink = "MobileLink"
        case link = "Link"
    }
}

struct Temperature: Codable {
    let value: Double
    let unit: String
    let unitType: Int
    
    enum CodingKeys: String, CodingKey {
        case value = "Value"
        case unit = "Unit"
        case unitType = "UnitType"
    }
}
