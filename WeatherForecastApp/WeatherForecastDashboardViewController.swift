//
//  WeatherForecastDashboardViewController.swift
//  WeatherForecastApp
//
//  Created by Rohit Sankpal on 08/06/23.
//

import UIKit
import CoreLocation

class WeatherForecastDashboardViewController: UIViewController {
    @IBOutlet var viewCityListTblBack: UIView!
    @IBOutlet weak var btnLocationOutlet: UIButton!
    @IBOutlet weak var spinnerOutlet: UIActivityIndicatorView!
    
    @IBOutlet weak var viewSpinnerBack: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblMainWeather: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var tblViewCityListOutlet: UITableView!
    var locationManager = CLLocationManager()
    
    var currentLocation: CLLocation!
    var currentLat = ""
    var currentLong = ""
    var arraySelectedCities = [String]()
    var arrayOfCities = ["Pune","Mumbai","Kolhapur","Satara","Ahmandnagar","Solapur","Sangli","Nagpur","Nashik","Raigad"]
    var arrayCheckmark = [0]

    override func viewDidLoad() {
        super.viewDidLoad()
        uiChanges()
        arraySelectedCities.removeAll()
        tblViewCityListOutlet.reloadData()
    }
    func uiChanges(){
        viewSpinnerBack.isHidden = true
        spinnerOutlet.isHidden = true
        btnLocationOutlet.titleLabel?.text = ""
        locationManager.requestWhenInUseAuthorization()
            
        switch locationManager.authorizationStatus {
        case .restricted, .denied:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            currentLocation = locationManager.location
            getCityFromCurrentLocation() // Calling api when location permissioin granted
            break
        case .authorizedAlways:
            currentLocation = locationManager.location
            getCityFromCurrentLocation() // Calling api when location permissioin granted
            break
        default:
            locationManager.requestWhenInUseAuthorization()
            break
        }
        
        tblViewCityListOutlet.delegate = self
        tblViewCityListOutlet.dataSource = self
    }
    @IBAction func btnSelectCityClicked(_ sender: Any) {
        if arraySelectedCities.count != 0 || arraySelectedCities != nil{
            let selectedCity = arraySelectedCities.first ?? "Benglore"
            self.weatherApiCall(city: selectedCity)
        }
    }
    
    @IBAction func buttonCurrentLocationClicked(_ sender: Any) {
        let geoCoder = CLGeocoder()
        guard currentLocation != nil else {
            return
        }
        
        btnLocationOutlet.titleLabel?.text = ""
        let clLocation = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        geoCoder.reverseGeocodeLocation(clLocation) { placeMark, error in
            guard let placeMark = placeMark else{
                print("error:\(String(describing: error))")
                return
            }
            print(placeMark.first?.locality ?? "")
            if let city = placeMark.first?.locality{
                self.weatherApiCall(city: city)
            }else{
                self.weatherApiCall(city:"Pune")
            }
        }
        
        currentLat = "\(currentLocation.coordinate.latitude)"
        currentLong = "\(currentLocation.coordinate.longitude)"
        
    }
    //This will call on clicked of current location button and When app launched
    func getCityFromCurrentLocation(){
        let geoCoder = CLGeocoder()
       
        if currentLocation != nil {
            
            let clLocation = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            geoCoder.reverseGeocodeLocation(clLocation) { placeMark, error in
                guard let placeMark = placeMark else{
                    print("error:\(String(describing: error))")
                    return
                }
                print(placeMark.first?.locality ?? "")
                if let city = placeMark.first?.locality{
                    self.weatherApiCall(city: city)
                }else{
                    self.weatherApiCall(city:"Pune")
                }
            }
            
            currentLat = "\(currentLocation.coordinate.latitude)"
            currentLong = "\(currentLocation.coordinate.longitude)"
        }
    }
}
extension WeatherForecastDashboardViewController : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfCities.count
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblViewCityListOutlet.dequeueReusableCell(withIdentifier: "CityTableViewCell") as! CityTableViewCell
        if arrayCheckmark.count < arrayOfCities.count{
            arrayCheckmark.append(0)
        }
        if arrayCheckmark[indexPath.row] == 0{
            cell.imageView?.image = UIImage()
        }else{
            arraySelectedCities.append(arrayOfCities[indexPath.row])
            cell.imageView?.image = .checkmark
        }
        cell.lblCityName.text = arrayOfCities[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tblViewCityListOutlet.cellForRow(at: indexPath)
        if arrayCheckmark[indexPath.row] == 0 {
            arrayCheckmark[indexPath.row] = 1
        } else {
            arrayCheckmark[indexPath.row] = 0
        }
        tblViewCityListOutlet.reloadData()
    }
}

extension WeatherForecastDashboardViewController {
   
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func weatherApiCall(city:String) {
        viewSpinnerBack.isHidden = false
        spinnerOutlet.isHidden = false
        spinnerOutlet.startAnimating()
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&APPID=e03e97822c6c03c0792076649946bce0") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            do {
                guard let jsonData = data else {
                    throw JSONError.NoData
                }
                
                let model = try JSONDecoder().decode(WeatherData.self, from: jsonData)
                
                if model.cod == 200 {
                 
                    DispatchQueue.main.async {
                        
                        self.lblDescription.text = model.weather.first?.description ?? ""
                        self.lblMainWeather.text = model.weather.first?.main ?? ""
                        self.lblLocation.text = model.name
                        self.lblCountry.text = model.sys.country
                        
                        self.viewSpinnerBack.isHidden = true
                        self.spinnerOutlet.isHidden = true
                        self.spinnerOutlet.stopAnimating()
                        self.tblViewCityListOutlet.reloadData()
                    }
                }
            } catch let error {
                
                print(error.localizedDescription)
            }
        }.resume()
    }
    
}
