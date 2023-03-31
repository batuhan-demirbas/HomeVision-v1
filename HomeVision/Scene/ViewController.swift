//
//  ViewController.swift
//  HomeVision
//
//  Created by Batuhan on 26.03.2023.
//

import UIKit
import FirebaseDatabase
import FirebaseCore
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var gasIcon: UIImageView!
    @IBOutlet weak var gasIconView: UIView!
    @IBOutlet weak var gasStateLabel: UILabel!
    @IBOutlet weak var gasWarningIcon: UIImageView!
    
    @IBOutlet weak var lampIconView: UIView!
    @IBOutlet weak var lampStateLabel: UILabel!
    @IBOutlet weak var lampSwitch: UISwitch!
    
    @IBOutlet weak var ventilationStateLabel: UILabel!
    @IBOutlet weak var ventilationIcon: UIImageView!
    @IBOutlet weak var ventilationSlider: UISlider!
    @IBOutlet weak var ventilationSwitch: UISwitch!
    
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var cameraIconView: UIView!
    @IBOutlet weak var cameraStateLabel: UILabel!
    @IBOutlet weak var cameraWarningIcon: UIImageView!
    
    var locationManager: CLLocationManager?
    let defaults = UserDefaults.standard
    let viewModel = HomeViewModel()
    var animationDuration: Double = 2
    var weather: Weather?
    var city : String?
    private let database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        city = defaults.string(forKey: "City") ?? "izmir"
        locationButton.titleLabel?.text = city?.capitalized
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        let formattedDateAndDay = getFormattedDateAndDay()
        dateLabel.text = formattedDateAndDay.date
        dayLabel.text = formattedDateAndDay.day
        
        ventilationSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        
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
            self.setState(sensorType: "gas" , isOn: home?.gas ?? false)
            self.setState(sensorType: "lamp", isOn: home?.lamp ?? false)
            self.setState(sensorType: "ventilation", isOn: home?.ventilation ?? false)
            self.setState(sensorType: "camera", isOn: home?.camera ?? false)
        })
        
        database.child("user").child("name").observe(.value) { snapshot in
            self.nameLabel.text = "hi, \((snapshot.value as? String)?.lowercased() ?? "null")"
        }
        
        database.child("home").child("gas").observe(.value) { snapshot in
            if (snapshot.value) as! Int  == 1 {
                self.setState(sensorType: "gas", isOn: true)
            } else {
                self.setState(sensorType: "gas", isOn: false)
            }
        }
        
        database.child("home").child("temperature").observe(.value) { snapshot in
            self.temperatureLabel.text = "\(snapshot.value ?? 0)°C"
        }
        
        database.child("home").child("camera").observe(.value) { snapshot in
            if (snapshot.value) as! Int  == 1 {
                self.setState(sensorType: "camera", isOn: true)
            } else {
                self.setState(sensorType: "camera", isOn: false)
            }
        }
        
        viewModelConfiguration()
        
    }
    
    fileprivate func viewModelConfiguration() {
        viewModel.getCurrentWeather(cityName: city ?? "izmir")
        viewModel.errorCallback = { [weak self] errorMessage in
            print("error: \(errorMessage)")
        }
        viewModel.succesCallback = { [self] in
            self.weather = self.viewModel.weather
            switch self.weather?.weather?.first?.main {
            case "Snow":
                weatherIcon.image = UIImage(named: "snow")
            case "Rain":
                weatherIcon.image = UIImage(named: "rain")
            case "Thunderstorm":
                weatherIcon.image = UIImage(named: "thunderstorm")
            case "Drizzle":
                weatherIcon.image = UIImage(named: "rain.shower")
            case "Clear":
                weatherIcon.image = UIImage(named: "sun")
            case "Mist", "Fog":
                weatherIcon.image = UIImage(named: "Fog")
            case "Clouds":
                weatherIcon.image = UIImage(named: "cloud.broken")
            default:
                weatherIcon.image = UIImage(named: "sun")
            }
            weatherIcon.tintColor = UIColor(named: "primary")
            weatherLabel.text = convertKelvinToCelsius(Kelvin: viewModel.weather?.main?.temp ?? 273.15)
        }
    }
    
    func convertKelvinToCelsius(Kelvin: Double) -> String {
        let celsius = Int(Kelvin - 273.15)
        return "\(celsius)°C"
    }
    
    func getFormattedDateAndDay() -> (date: String, day: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd MMMM"
        let dateString = dateFormatter.string(from: Date())
        
        dateFormatter.dateFormat = "EEEE"
        let dayString = dateFormatter.string(from: Date())
        
        return (dateString, dayString)
    }
    
    func setState(sensorType: String, isOn: Bool) {
        
        enum DeviceTypes {
            case gas
            case lamp
            case ventilation
            case camera
        }
        
        switch sensorType {
        case "gas":
            if isOn {
                gasIcon.tintColor = .white
                gasIconView.backgroundColor = UIColor(named: "warning")
                gasStateLabel.text = "gas detected"
                gasStateLabel.textColor = UIColor(named: "warning")
                gasWarningIcon.isHidden = false
                UIView.animate(withDuration: 1, delay: 0.0, options: [.repeat, .autoreverse], animations: {
                    self.gasIconView.alpha = 0.5
                }, completion: nil)
            } else {
                gasIconView.layer.removeAllAnimations()
                gasIconView.alpha = 1.0
                gasIcon.tintColor = UIColor(named: "secondry")
                gasIconView.backgroundColor = .white
                gasStateLabel.text = "no gas detected"
                gasStateLabel.textColor = UIColor(named: "light")
                gasWarningIcon.isHidden = true
            }
        case "lamp":
            if isOn {
                lampIconView.backgroundColor = UIColor(named: "lamp")
                lampSwitch.isOn = true
                lampStateLabel.text = "on"
                database.child("home").child("lamp").setValue(true)
            } else {
                lampIconView.backgroundColor = .white
                lampSwitch.isOn = false
                lampStateLabel.text = "off"
                database.child("home").child("lamp").setValue(false)
            }
        case "ventilation":
            if isOn {
                ventilationSwitch.isOn = true
                ventilationSlider.isEnabled = true
                ventilationStateLabel.text = "on"
                UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveLinear, .repeat], animations: {
                            self.ventilationIcon.transform = self.ventilationIcon.transform.rotated(by: .pi)
                        })
                database.child("home").child("ventilation").setValue(true)
                
            } else {
                ventilationSwitch.isOn = false
                ventilationSlider.isEnabled = false
                ventilationStateLabel.text = "off"
                ventilationIcon.layer.removeAllAnimations()
                database.child("home").child("ventilation").setValue(false)
            }
        case "camera":
            if isOn {
                cameraIcon.tintColor = .white
                cameraIconView.backgroundColor = UIColor(named: "warning")
                cameraStateLabel.text = "motion detected"
                cameraStateLabel.textColor = UIColor(named: "warning")
                cameraWarningIcon.isHidden = false
                UIView.animate(withDuration: 1, delay: 0.0, options: [.repeat, .autoreverse], animations: {
                    self.cameraIconView.alpha = 0.5
                }, completion: nil)
            } else {
                cameraIconView.layer.removeAllAnimations()
                cameraIconView.backgroundColor = .white
                cameraIconView.alpha = 1.0
                cameraIcon.tintColor = UIColor(named: "secondry")
                cameraStateLabel.text = "no motion detected"
                cameraStateLabel.textColor = UIColor(named: "light")
                cameraWarningIcon.isHidden = true
            }
        default:
            break
        }
    }
    
    @IBAction func ventilationSwitchDidChangeValue(_ sender: UISwitch) {
        animationDuration = Double(1 / ventilationSlider.value * 1.5)
        setState(sensorType: "ventilation", isOn: sender.isOn)
    }
    
    @IBAction func lampSwitchDidChangeValue(_ sender: UISwitch) {
        setState(sensorType: "lamp", isOn: sender.isOn)
    }
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        LocationManager.shared.getUserLocation {[weak self] location in
            let longitude = location.coordinate.longitude
            let latitude = location.coordinate.latitude
            LocationManager.shared.reverseGeocoding(latitude: latitude, longitude: longitude) { placemark in
                let cityName = placemark.administrativeArea
                self?.locationButton.setTitle(cityName, for: .normal)
                if let customFont = UIFont(name: "Gilroy", size: 11) {
                    self?.locationButton.titleLabel?.font = customFont
                }
                self?.city = cityName?.lowercased() ?? "Ankara"
                self?.defaults.set(cityName?.lowercased(), forKey: "City")
                self?.viewModelConfiguration()
            }

            DispatchQueue.main.async {
                guard let self = self else { return }
                
            }
        }
    }
    
    @IBAction func ventilationSliderDidChangeValue(_ sender: UISlider) {
        animationDuration = 1 / Double(sender.value) * 1.5
        setState(sensorType:"ventilation", isOn: true)
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
}

