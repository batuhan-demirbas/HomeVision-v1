//
//  NetworkHeloper.swift
//  HomeVision
//
//  Created by Batuhan on 27.03.2023.
//

import Foundation

enum ErrorTypes: String, Error {
    case invalidData = "Invalid data"
    case invalidUrl = "invalid url"
    case generalError = "An error happened"
}

class NetworkHelper {
    static let shared = NetworkHelper()
    
    var baseURL = "https://api.openweathermap.org/data/2.5"
    var apiKey = "f0b5a39eaea36f59608594bbce721804"
    
    func requestUrl(url: String) -> String {
        baseURL + url + "?appid=\(apiKey)"
    }
}
