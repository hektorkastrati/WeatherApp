//
//  Moti.swift
//  Weather
//
//  Created by Hektor Kastrati on 10/9/18.
//  Copyright © 2018 Hektor Kastrati. All rights reserved.
//

import Foundation

class Moti{
    
    let qyteti:String
    let shteti:String
    let ikona:String
    let temperatura:Double
    
    init(emriIQytetit:String, emriIShtetit:String, ikona:String, temperaturaNeKelvin:Double) {
        
        qyteti = emriIQytetit
        shteti = emriIShtetit
        self.ikona = ikona
        temperatura = temperaturaNeKelvin
    }
    
    func konvertoNeCelsius() -> String {
        
        let tempC = temperatura - 273.15
        
        return"\(String(format: "%.2f", tempC)) C"
    }
    
    func konvertoNeFahrenheit() -> String {
        
        let tempF:Double = temperatura * 9/5 - 459.67
        return"\(String(format: "%.2f", tempF)) F"
    }
    
    func ikonaURL() -> String {
        
        let ikonaURL:String = "https://openweathermap.org/img/w/\(ikona).png"
        return ikonaURL
    }
}
