//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation // get hold of local location

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    
    // locationManager is responsible for getting hold of current GPS location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self // set this class as delegate of CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization() // the pop-up asking for permission
        locationManager.requestLocation() // this triggers didUpdateLoactions func
        
        // set this class as a delegate of WeatherManagerDelegate
        weatherManager.delegate = self
        
        // set this class as delegate of UITextField
        searchTextField.delegate = self
    }

}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        // endEditing(true) is to dismiss the keyboard after we hit search button
        searchTextField.endEditing(true)
    }
    
    // the delegate calls this method when the users tap the return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // endEditing(true) is to dismiss the keyboard after we hit return button
        searchTextField.endEditing(true)
        return true
    }
    
    // this delegate method is to check the UITextField before it can go to textFieldDidEndEditing().
    // if the textField is NOT empty, it returns true to let UITextFiled to go to textFieldDidEndEditing()
    // if textField is empty, it returns false and textFieldDidEndEditing() cannot be executed.
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    // this delegate method is called when we finish editing the textField, we can understand this as it is run after we hit the return button and searchTextField.endEditing() is executed.
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // searchTextField.text is optional, so we optianl binding it
        // and use it as parameter for the fetchWeather()
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        
        // empty the textField after we finish.
        searchTextField.text = ""
        
    }
}

//MARK: - WeatherManagerDelegate


extension WeatherViewController: WeatherManagerDelegate {
    // By convention, first parameter of delegate methods is the object that calls the method
    // in this case it is WeatherManager and obmit external parameter.
    // this still works without the first parameter, this is just Swift's convention.
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        // Rememer: the data we receive from server is cooked and finished by Completion Handler in WeatherManager.swift
        // so when we want to work with data insdie Completion Handler we have to use DispatchQueue.main.async
        DispatchQueue.main.async {
            // Use values from WeatherModel to update UILabel
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName) // Use the returned String to set the image.
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate


extension WeatherViewController: CLLocationManagerDelegate {
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
        // When users tap location button, locationManager.requestLocation() runs,
        // it triggers didUpdateLocations func to get the weather data from current location
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // tap into the last item of the array [CLLocation] to get the latest location
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            // see explaination at the end of this
            
            // latitude and longtitude
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            // fetch weather data using longtitude and latitude of current location
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

/* locationManager.stopUpdatingLocation()
 - When we first start the app, the locationManager.requestLocation in ViewDidLoad() runs, triggers didUpdateLocation(), fetch data for current location based on latitude and longtitude.
 - But later on if we hit location button while still using the app, because we are still at same place so didUpdateLocation() cannot be triggered, we can't go back to current location weather. That's why we use locationManager.stopUpdatingLocation() so that after finishing getting the current location when we first start the app, it stop updating location and we click on location button again, the app will give us the weather of current location.
*/
