//
//  Home.swift
//  HomeVision
//
//  Created by Batuhan on 27.03.2023.
//

import Foundation

struct Home: Codable {
    
    let temperature: Int
    let humidity: Int
    let lamp: Bool
    let gas: Bool
    let camera: Bool
    let ventilation: Ventilation
    
    init?(data: [String:Any]) {
        guard let temperature = data["temperature"] as? Int,
              let humiditiy = data["humidity"] as? Int,
              let gas = data["gas"] as? Bool,
              let camera = data["camera"] as? Bool,
              let ventilationData = data["ventilation"] as? [String:Any],
              let isOn = ventilationData["isOn"] as? Bool,
              let speed = ventilationData["speed"] as? Int,
              let lamp = data["lamp"] as? Bool else {
            return nil
        }
        self.temperature = temperature
        self.humidity = humiditiy
        self.lamp = lamp
        self.gas = gas
        self.camera = camera
        self.ventilation = Ventilation(isOn: isOn, speed: speed)
    }
    
}

struct Ventilation: Codable {
    let isOn: Bool
    let speed: Int
    
}
