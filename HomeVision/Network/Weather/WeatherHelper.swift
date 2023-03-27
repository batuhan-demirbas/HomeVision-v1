//
//  WeatherHelper.swift
//  HomeVision
//
//  Created by Batuhan on 27.03.2023.
//

import Foundation

enum WeatherEndpoint: String {
    case weather = "/weather"
    
    func path() -> String {
        return NetworkHelper.shared.requestUrl(url: WeatherEndpoint.weather.rawValue)
    }
}
