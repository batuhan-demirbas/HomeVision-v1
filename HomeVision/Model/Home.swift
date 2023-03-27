//
//  Home.swift
//  HomeVision
//
//  Created by Batuhan on 27.03.2023.
//

import Foundation

struct Home: Codable {

        let temperature: Double
        let humidity: Double

        init?(data: [String:Any]) {
            guard let temperature = data["temperature"] as? Double,
                  let humidity = data["humidity"] as? Double else {
                return nil
            }
            self.temperature = temperature
            self.humidity = humidity
        }

    
}
