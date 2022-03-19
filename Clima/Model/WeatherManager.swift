//
//  WeatherManager.swift
//  Clima
//
//  Created by Dmitriy on 3/17/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    var weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=6ff5ead26044a177650a24c85abbcc11"
    
    func fetchWeather(cityName: String, units: String) {
        let urlString = "\(weatherURL)&units=\(units)&q=\(cityName.replacingOccurrences(of: " ", with: "%20"))"
        performRequest(with: urlString)
    }
    
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees, units: String) {
        let urlString = "\(weatherURL)&units=\(units)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJson(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJson(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let city = decodedData.name
            let country = decodedData.sys.country
            let weather = WeatherModel(conditionId: id, cityName: city, countryName: country, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
    
    func farToCel(_ temp: Double) -> String {
        return String(format: "%.1f", (temp - 32) * 5 / 9)
    }
    
    func celToFar(_ temp: Double) -> String {
        return String(format: "%.1f", temp * 9 / 5 + 32)
    }
}
