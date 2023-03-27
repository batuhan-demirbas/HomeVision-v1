//
//  WeatherManager.swift
//  HomeVision
//
//  Created by Batuhan on 27.03.2023.
//

import Foundation

protocol WeatherManagerProtocol {
    func getCurrentWeather(cityName: String, complete: @escaping((Weather?, Error?)->()))
}

class WeatherManager: WeatherManagerProtocol {
    static let shared = WeatherManager()
    
    func getCurrentWeather(cityName: String, complete: @escaping((Weather?, Error?)->())) {
        NetworkManager.shared.request(type: Weather.self, url: WeatherEndpoint.weather.path() + "&q=\(cityName)", method: .get) { response in
            switch response {
            case .success(let data):
                print(response)
                complete(data, nil)
            case.failure(let error):
                complete(nil, error)
            }
        }
    }
    
}
