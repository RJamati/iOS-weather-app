//
//  WeatherManager.swift
//  Clima
//
//  Created by Rukhsar Jamati on 05/06/2020.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager{
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid="Your API Key"&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        
        print("URL=\(urlString)")
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude : CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        print("URL=\(urlString)")
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String){
        //1 Create a URL
        if  let url = URL(string: urlString){
            //2 Create URL Session
            let session = URLSession(configuration: .default)
            //3 Give the session a task
             // let task = session.dataTask(with: url, completionHandler: handle(data:response:error:))
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    print(error!)
                    //exit the if statement and return to next line
                    return
                }
                
                if let safeData = data { 
                   // let dataString = String(data : safeData, encoding: .utf8)
                   // print(dataString)
                   if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                    
                }
            }
            //4 Start the task
            task.resume()
        }
    }

      func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            print(weather.conditionName)
            //print(weather.getConditionName(weatherId: id))
            print(weather.temperatureString)
            //print(decodedData.weather[0].description)
            return weather
        } catch{
             delegate?.didFailWithError(error: error)
             return nil
        }
    }
    
  
}
