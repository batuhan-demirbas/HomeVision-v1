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
    
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var gasIconView: UIView!
    @IBOutlet weak var gasIcon: UIImageView!
    @IBOutlet weak var gasStateLabel: UILabel!
    @IBOutlet weak var gasWarningIcon: UIImageView!
    
    @IBOutlet weak var ventilationSlider: UISlider!
    @IBOutlet weak var ventilationSwitch: UISwitch!
    
    @IBOutlet weak var lampIconView: UIView!
    @IBOutlet weak var lampIcon: UIImageView!
    @IBOutlet weak var lampStateLabel: UILabel!
    @IBOutlet weak var lampSwitch: UISwitch!
    
    
    let viewModel = HomeViewModel()
    var weather: Weather?
    private let database = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let formattedDateAndDay = getFormattedDateAndDay()
        
        ventilationSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        
        dateLabel.text = formattedDateAndDay.date
        dayLabel.text = formattedDateAndDay.day
        
        database.child("user").getData(completion:  { error, snapshot in
          guard error == nil else {
            print(error!.localizedDescription)
            return
          }
            guard let value = snapshot?.value else { return }
            let user = User(data: value as! [String : Any])
            self.nameLabel.text = "hi, \(user?.name.lowercased() ?? "null")"
        })
        
        database.child("home").getData(completion:  { error, snapshot in
          guard error == nil else {
            print(error!.localizedDescription)
            return
          }
            guard let value = snapshot?.value else { return }
            let home = Home(data: value as! [String : Any])
            self.temperatureLabel.text = "\(Int(home?.temperature ?? 0))°C"
        })
        viewModelConfiguration()
        
        
    }
    
    fileprivate func viewModelConfiguration() {
        viewModel.getCurrentWeather(cityName: "Bursa")
        viewModel.errorCallback = { [weak self] errorMessage in
            print("error: \(errorMessage)")
        }
        viewModel.succesCallback = { [self] in
            self.weather = self.viewModel.weather
            weatherLabel.text = convertKelvinToCelsius(Kelvin: viewModel.weather?.main?.temp ?? 273.15)
            
        }
    }
    
    func convertKelvinToCelsius(Kelvin: Double) -> String {
        let celsius = Int(Kelvin - 273.15)
        return "\(celsius)°C"
    }
    
    func getFormattedDateAndDay() -> (date: String, day: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        let dateString = dateFormatter.string(from: Date())

        dateFormatter.dateFormat = "EEEE"
        let dayString = dateFormatter.string(from: Date())

        return (dateString, dayString)
    }
    
    @IBAction func ventilationSwitchDidChangeValue(_ sender: UISwitch) {
        if sender.isOn {
            ventilationSlider.isEnabled = true
        } else {
            ventilationSlider.isEnabled = false
        }
    }
    
    @IBAction func lampSwitchDidChangeValue(_ sender: UISwitch) {
        if sender.isOn {
            lampIcon.tintColor = .white
            lampIconView.backgroundColor = UIColor(named: "primary")
            lampStateLabel.text = "on"
            database.child("home").child("lamp").setValue(true)
        } else {
            lampIcon.tintColor = UIColor(named: "secondry")
            lampIconView.backgroundColor = .white
            lampStateLabel.text = "off"
            database.child("home").child("lamp").setValue(false)
        }
    }

    


}

