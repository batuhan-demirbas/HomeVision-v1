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
    
    @IBOutlet weak var gasIcon: UIImageView!
    @IBOutlet weak var gasIconView: UIView!
    @IBOutlet weak var gasStateLabel: UILabel!
    @IBOutlet weak var gasWarningIcon: UIImageView!
    
    @IBOutlet weak var lampStateLabel: UILabel!
    @IBOutlet weak var lampSwitch: UISwitch!
    
    @IBOutlet weak var ventilationStateLabel: UILabel!
    @IBOutlet weak var ventilationSlider: UISlider!
    @IBOutlet weak var ventilationSwitch: UISwitch!
    
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var cameraIconView: UIView!
    @IBOutlet weak var cameraStateLabel: UILabel!
    @IBOutlet weak var cameraWarningIcon: UIImageView!
    
    let viewModel = HomeViewModel()
    var weather: Weather?
    private let database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            self.setState(deviceType: "gas", isOn: home?.gas ?? false)
            self.setState(deviceType: "lamp", isOn: home?.lamp ?? false)
            self.setState(deviceType: "ventilation", isOn: home?.ventilation ?? false)
            self.setState(deviceType: "camera", isOn: home?.camera ?? false)
        })
        
        
        database.child("home").child("gas").observe(.value) { snapshot in
            if (snapshot.value) as! Int  == 1 {
                self.setState(deviceType: "gas", isOn: true)
            } else {
                self.setState(deviceType: "gas", isOn: false)
            }
        }
        
        database.child("home").child("camera").observe(.value) { snapshot in
            if (snapshot.value) as! Int  == 1 {
                self.setState(deviceType: "camera", isOn: true)
            } else {
                self.setState(deviceType: "camera", isOn: false)
            }
        }
        
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
    
    func setState(deviceType: String, isOn: Bool) {
        switch deviceType {
        case "gas":
            if isOn {
                gasIcon.tintColor = .white
                gasIconView.backgroundColor = UIColor(named: "warning")
                gasStateLabel.text = "gas detected"
                gasStateLabel.textColor = UIColor(named: "warning")
                gasWarningIcon.isHidden = false
            } else {
                gasIcon.tintColor = UIColor(named: "secondry")
                gasIconView.backgroundColor = .white
                gasStateLabel.text = "no gas detected"
                gasStateLabel.textColor = UIColor(named: "light")
                gasWarningIcon.isHidden = true
            }
        case "lamp":
            if isOn {
                lampSwitch.isOn = true
                lampStateLabel.text = "on"
                database.child("home").child("lamp").setValue(true)
            } else {
                lampSwitch.isOn = false
                lampStateLabel.text = "off"
                database.child("home").child("lamp").setValue(false)
            }
        case "ventilation":
            if isOn {
                ventilationSwitch.isOn = true
                ventilationSlider.isEnabled = true
                ventilationStateLabel.text = "on"
                database.child("home").child("ventilation").setValue(true)
                
            } else {
                ventilationSwitch.isOn = false
                ventilationSlider.isEnabled = false
                ventilationStateLabel.text = "off"
                database.child("home").child("ventilation").setValue(false)
            }
        case "camera":
            if isOn {
                cameraIcon.tintColor = .white
                cameraIconView.backgroundColor = UIColor(named: "warning")
                cameraStateLabel.text = "motion detected"
                cameraStateLabel.textColor = UIColor(named: "warning")
                cameraWarningIcon.isHidden = false
            } else {
                cameraIcon.tintColor = UIColor(named: "secondry")
                cameraIconView.backgroundColor = .white
                cameraStateLabel.text = "no motion detected"
                cameraStateLabel.textColor = UIColor(named: "light")
                cameraWarningIcon.isHidden = true
            }
        default:
            break
        }
    }
    
    @IBAction func ventilationSwitchDidChangeValue(_ sender: UISwitch) {
        setState(deviceType: "ventilation", isOn: sender.isOn)
    }
    
    @IBAction func lampSwitchDidChangeValue(_ sender: UISwitch) {
        setState(deviceType: "lamp", isOn: sender.isOn)
    }
    
}

