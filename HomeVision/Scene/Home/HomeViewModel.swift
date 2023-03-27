//
//  HomeViewModel.swift
//  HomeVision
//
//  Created by Batuhan on 27.03.2023.
//

import Foundation

class HomeViewModel {
    let manager = WeatherManager.shared
    
    var weather: Weather?
    var errorCallback: ((String)->())?
    var succesCallback: (()->())?
    
    func getCurrentWeather(cityName: String) {
        manager.getCurrentWeather (cityName: cityName, complete: { [weak self] weather, error in
            guard let self = self else { return }
            if let error = error {
                self.errorCallback?(error.localizedDescription)
            } else {
                self.weather = weather
                self.succesCallback?()
            }
        })
    }
    
}
