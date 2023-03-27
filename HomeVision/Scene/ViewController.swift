//
//  ViewController.swift
//  HomeVision
//
//  Created by Batuhan on 26.03.2023.
//

import UIKit
import FirebaseDatabase
import FirebaseCore

class ViewController: UIViewController {
    
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var humidity: UILabel!
    
    let viewModel = HomeViewModel()
    var weather: Weather?
    private let database = Database.database().reference(withPath: "home")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        database.getData(completion:  { error, snapshot in
          guard error == nil else {
            print(error!.localizedDescription)
            return
          }
            guard let value = snapshot?.value else { return }
            let home = Home(data: value as! [String : Any])
            self.temperature.text = String(home?.temperature ?? 0)
        })
        
        viewModelConfiguration()
    }
    
    fileprivate func viewModelConfiguration() {
        viewModel.getCurrentWeather(cityName: "bursa")
        viewModel.errorCallback = { [weak self] errorMessage in
            print("error: \(errorMessage)")
        }
        viewModel.succesCallback = { [self] in
            self.weather = self.viewModel.weather
            
            humidity.text = String(weather?.main?.humidity ?? 0)
            
        }
    }


}

