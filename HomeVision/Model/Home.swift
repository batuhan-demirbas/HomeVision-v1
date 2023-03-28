//
//  Home.swift
//  HomeVision
//
//  Created by Batuhan on 27.03.2023.
//

import Foundation

struct Home: Codable {
    
    let temperature: Int
    let lamp: Bool
    let gas: Bool
    let camera: Bool
    let ventilation: Bool
    
    init?(data: [String:Any]) {
        guard let temperature = data["temperature"] as? Int,
              let gas = data["gas"] as? Bool,
              let camera = data["camera"] as? Bool,
              let ventilation = data["ventilation"] as? Bool,
              let lamp = data["lamp"] as? Bool else {
            return nil
        }
        self.temperature = temperature
        self.lamp = lamp
        self.gas = gas
        self.camera = camera
        self.ventilation = ventilation
    }
    
    
}
