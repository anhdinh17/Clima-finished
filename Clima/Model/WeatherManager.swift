//
//  WeatherManager.swift
//  Clima
//
//  Created by Angela Yu on 03/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    // first parameter is Swift Convention
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=e72ca729af228beabd5d20e3b7749713&units=imperial"
    
    var delegate: WeatherManagerDelegate?
    
    // fetch data of the city we type in
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)" // url with the query of city name.
        performRequest(with: urlString) // perform networking
    }
    
    // fetch data of current location
    // Swift is ok with funcs with same name, as long as they have different parameters.
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        // Networking
        
        // 1.Create URL
        // URL is optional so we optinal binding
        if let url = URL(string: urlString) {
            // 2.Create a URLSession
            // this is like a browser that can perform the networking
            let session = URLSession(configuration: .default)
            
            // 3.Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in //data is raw data from JSON
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data { // because data is optional Data, optional binding it
                    if let weather = self.parseJSON(safeData) { // because parseJSON returns an optional,optional binding it
                        // whichever class that set itself as a delegate,
                        // will excecute its own didUpdateWeather() func
                        // with the same parameters as this one below
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // 4.Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder() // this is to decode the raw JSON data
        do {
            // WeatherData.self is the Data Type (in this case it's the structure that we want our data to be formed)
            // so the return of decode() is a WeatherData struct and decodedData is an instance of WeatherData struct
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            // use the values above to create an object of WeatherModel
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
            // we return nil in case the do-block fails
            // that also makes this function to return optional Data Type
            // that's why we put ? after WeatherModel in the return
        }
    }
    
}

/*
 Completion Handler: take a function as an input ----> Closure
 completion handler is used when it completes its task/function. Think of it as this, let it there and run,
 when it's done, we use its result.
 
 short form of closure: we don't need Data Type for parameters.
 */
