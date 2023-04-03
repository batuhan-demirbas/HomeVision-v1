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

class WeatherHelper {
    func getWeatherIcon(weatherId: Int) -> WeatherIcon {
        switch weatherId {
        case 200...232:
            return .thunderstorm
        case 300...321:
            return .rainShower
        case 500...504:
            return .rain
        case 511:
            return .snow
        case 520...531:
            return .rainShower
        case 600...622:
            return .snow
        case 701...781:
            return .fog
        case 800:
            return .sun
        case 801:
            return .cloudFew
        case 802:
            return .cloud
        case 803, 804:
            return .cloudBroken
        default:
            return .sun
        }
    }
}
