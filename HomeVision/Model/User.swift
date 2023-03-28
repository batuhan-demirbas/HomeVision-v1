//
//  User.swift
//  HomeVision
//
//  Created by Batuhan on 28.03.2023.
//

import Foundation

struct User: Codable {

        let name: String
        let surname: String

        init?(data: [String:Any]) {
            guard let name = data["name"] as? String,
                  let surname = data["surname"] as? String else {
                return nil
            }
            self.name = name
            self.surname = surname
        }

    
}
