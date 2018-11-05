//
//  ViewController.swift
//  Weather
//
//  Created by Hektor Kastrati on 10/9/18.
//  Copyright © 2018 Hektor Kastrati. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import CoreLocation
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, MotiDelegate {

    @IBOutlet weak var lblQyteti: UILabel!
    @IBOutlet weak var lblTemperatura: UILabel!
    @IBOutlet weak var switchOut: UISwitch!
   @IBOutlet weak var imgIkona: UIImageView!
    
    
    var motiIZgjedhur:Moti? = nil
    let API_URL = "https://api.openweathermap.org/data/2.5/weather"
    let API_KEY = "9c3f177b5d8e2eec5df2c8fdf52b94b9"
    var locationManager:CLLocationManager!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var context:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblQyteti.text = "Kerko Qytetin"
        lblTemperatura.text = ""
        
        locationManager = CLLocationManager.init()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
         context = appdelegate.persistentContainer.viewContext
        
    }
    
    
   

   // @IBAction func btnKerko(_ sender: Any) {
        
   //     if(lblTeksti.text != ""){
            
     //       let params:[String:String] = ["q":lblTeksti.text!, "appid":API_KEY]
            
       //     merrKohen(params: params)
            
       // }else{
            
          // lblQyteti.text = "Sheno Qytetin"
         //  lblTemperatura.text = ""
        //}
   // }
    
    
    @IBAction func switchChanged(_ sender: Any) {
        
        if(motiIZgjedhur != nil ){
            
            rifreskoPamjen()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocation = locations[0]
        if (location.horizontalAccuracy > 0) {
            
            locationManager.stopUpdatingHeading()
            var latitude =  String(location.coordinate.latitude)
            var longitude = String(location.coordinate.longitude)
            
            let params:[String:String] = ["lat":latitude, "lon":longitude, "appid":API_KEY]
            
            merrKohen(params: params)
        }
    }
    
    
    func merrKohen(params:[String:String]){
        
        Alamofire.request(API_URL, method: .get, parameters: params).responseData{ (responseData) in
            
            if responseData.result.isSuccess{
                
                var weatherJSON = try! JSON(responseData.result.value)
                
                var ikona = weatherJSON["weather"][0]["icon"].stringValue
                
                var emriIQyteti = weatherJSON["name"].stringValue
                
                var emriIShtetit = weatherJSON["sys"]["country"].stringValue
                
                var temperatura = weatherJSON["main"]["temp"].doubleValue
                
                var moti:Moti = Moti.init(emriIQytetit: emriIQyteti, emriIShtetit: emriIShtetit, ikona: ikona, temperaturaNeKelvin: temperatura)
                
                self.motiIZgjedhur = moti
                self.rifreskoPamjen()
                
            }else{
                
                print("Gabim gjate lidhjes me API")
            }
            
        }
    }
    
    func rifreskoPamjen(){
        
        lblQyteti.text = motiIZgjedhur!.qyteti + ", " + motiIZgjedhur!.shteti
        
        if(switchOut.isOn){
            
            lblTemperatura.text = motiIZgjedhur!.konvertoNeFahrenheit()
        }else{
            
            lblTemperatura.text = motiIZgjedhur!.konvertoNeCelsius()
        }
        
        let url:URL = URL(string: motiIZgjedhur!.ikonaURL())!
        
        imgIkona.af_setImage(withURL: url)
    }
    
    @IBAction func btnMotiDetaje(_ sender: Any) {
        
        performSegue(withIdentifier: "View2", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "View2"){
            let menu2ViewController = segue.destination as! Controller2view
            menu2ViewController.delegate = self
        }
    }
    
    func updateMotin(moti:Moti) {
        
        //imgIkona.image = UIImage.init(named: moti.ikonaURL())
        //lblQyteti.text = moti.qyteti + ", " + moti.shteti
        //lblTemperatura.text = String(moti.temperatura)
        //pershkrimiUshqimi.text = ushqimi.pershkrimi
        motiIZgjedhur = moti
        //print("Test")
        rifreskoPamjen()
    }
    
    @IBAction func btnFavorit(_ sender: Any) {
        
        if(motiIZgjedhur != nil){
            
            let motiIRi = NSEntityDescription.insertNewObject(forEntityName: "Motet", into: self.context)
            motiIRi.setValue(motiIZgjedhur?.ikona, forKey: "ikona")
            motiIRi.setValue(motiIZgjedhur?.qyteti, forKey: "qyteti")
            motiIRi.setValue(motiIZgjedhur?.shteti, forKey: "shteti")
            motiIRi.setValue(motiIZgjedhur?.temperatura, forKey: "temperatura")
            
            do{
                try context.save()
            }catch{
                print("Gabim gjate ruajtejes se te dhenave")
            }
        }
    }
    
    
}

