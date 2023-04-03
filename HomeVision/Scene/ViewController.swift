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
    @IBOutlet weak var temperatureIcon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var gasIcon: UIImageView!
    @IBOutlet weak var gasIconView: UIView!
    @IBOutlet weak var gasStateLabel: UILabel!
    @IBOutlet weak var gasWarningIcon: UIImageView!
    
    @IBOutlet weak var lampIconView: UIView!
    @IBOutlet weak var lampIcon: UIImageView!
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
    var lat : String?
    var lon : String?
    private let database = Database.database().reference()
    
    var currentIndex = 0
    var timer: Timer?
    
    var temperature: Int = 0
    var humidity: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        city = defaults.string(forKey: "City") ?? "ankara"
        lat = defaults.string(forKey: "Lat") ?? "39,9249354"
        lon = defaults.string(forKey: "Lon") ?? "32,8366406"
        locationButton.titleLabel?.text = city?.capitalized
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        let formattedDateAndDay = getFormattedDateAndDay()
        dateLabel.text = formattedDateAndDay.date
        dayLabel.text = formattedDateAndDay.day
        
        timer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(updateWeather), userInfo: nil, repeats: true)

        ventilationSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        
        database.child("user").getData(completion:  { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let value = snapshot?.value else { return }
            let user = User(data: value as! [String : Any])
            self.nameLabel.text = "hi,\(user?.name.lowercased() ?? "null")"
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
            self.temperature = snapshot.value as! Int
        }
        
        database.child("home").child("humidity").observe(.value) { snapshot in
            self.humidity = snapshot.value as! Int
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
        viewModel.getCurrentWeather(lat: lat! , lon: lon! )
        viewModel.errorCallback = { [weak self] errorMessage in
            print("error: \(errorMessage)")
        }
        viewModel.succesCallback = { [self] in
            self.weather = self.viewModel.weather
            let icon = WeatherHelper().getWeatherIcon(weatherId: weather?.weather?.first?.id ?? 0)
            weatherIcon.image = UIImage(named: icon.rawValue)
            weatherIcon.tintColor = UIColor(named: "primary")
            weatherLabel.text = convertKelvinToCelsius(Kelvin: viewModel.weather?.main?.temp ?? 273.15)
            
            UIView.animate(withDuration: 5.0, delay: 0, options: [.repeat, .curveEaseInOut], animations: { [self] in
                if temperatureLabel.text == self.convertKelvinToCelsius(Kelvin: viewModel.weather?.main?.temp ?? 273.15) {
                    self.temperatureLabel.text = String(weather?.main?.humidity ?? 0)
                    self.temperatureIcon.image = UIImage(named: "droplet")
                } else {
                    temperatureLabel.text = convertKelvinToCelsius(Kelvin: viewModel.weather?.main?.temp ?? 273.15)
                    self.temperatureIcon.image = UIImage(named: "temperature")
                }
            })
            
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
                lampIcon.image = UIImage(named: "lamp.on")
                lampSwitch.isOn = true
                lampStateLabel.text = "on"
                database.child("home").child("lamp").setValue(true)
            } else {
                lampIcon.image = UIImage(named: "lamp.off")
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
            self?.lon = String(location.coordinate.longitude)
            self?.lat = String(location.coordinate.latitude)
            self?.defaults.set(self?.lat, forKey: "Lat")
            self?.defaults.set(self?.lon, forKey: "Lon")
            LocationManager.shared.reverseGeocoding(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { placemark in
                let cityName = placemark.administrativeArea
                self?.locationButton.setTitle(cityName, for: .normal)
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
    
    @objc func updateWeather() {
        // Metni ve resmi güncelle
            currentIndex = (currentIndex + 1) % 2
            
            // Animasyonlu şekilde metni ve resmi güncelle
        UIView.transition(with: temperatureLabel, duration: 0.7, options: [.transitionCrossDissolve], animations: {
                switch self.currentIndex {
                case 0:
                    self.temperatureLabel.text = String(self.temperature).addDegreeSymbol()
                    UIView.transition(with: self.temperatureIcon, duration: 0.7, options: [.transitionCrossDissolve], animations: {
                        self.temperatureIcon.image = UIImage(named: "temperature")
                    }, completion: nil)
                case 1:
                    self.temperatureLabel.text = "%" + String(self.humidity)
                    UIView.transition(with: self.temperatureIcon, duration: 0.7, options: [.transitionCrossDissolve], animations: {
                        self.temperatureIcon.image = UIImage(named: "droplet")
                    }, completion: nil)
                default:
                    self.temperatureLabel.text = "error"
                }
            }, completion: nil)
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
}

