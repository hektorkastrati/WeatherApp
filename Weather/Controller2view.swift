//
//  Controller2view.swift
//  Weather
//
//  Created by Hektor Kastrati on 10/12/18.
//  Copyright © 2018 Hektor Kastrati. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage
import CoreData

class Controller2view: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var lblTeskti: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let API_URL = "https://api.openweathermap.org/data/2.5/weather"
    let API_KEY = "9c3f177b5d8e2eec5df2c8fdf52b94b9"
    
    var motet:[Moti] = [Moti]()
    var delegate:MotiDelegate?
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var context:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("hello screen2")
        
            tableView.register(UINib.init(nibName:"MotiCellViewController", bundle: nil), forCellReuseIdentifier: "motiCell")
        
            tableView.delegate = self
            tableView.dataSource = self
        
            context = appdelegate.persistentContainer.viewContext
        
            //lexo te dhenat nga CoreData
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Motet")
            request.returnsObjectsAsFaults = false
        
            do{
               let results = try context.fetch(request)
                
                for moti in results as! [NSManagedObject]{
                
                    
                
                    let ikona:String = moti.value(forKey: "ikona") as! String
                    let emriIQyteti:String = moti.value(forKey: "qyteti") as! String
                    let emriIShtetit:String = moti.value(forKey: "shteti") as! String
                    let temperatura:Double = moti.value(forKey: "temperatura") as! Double
                    
                    let moti:Moti = Moti.init(emriIQytetit: emriIQyteti, emriIShtetit: emriIShtetit, ikona: ikona, temperaturaNeKelvin: temperatura)
                    motet.append(moti)
                    tableView.reloadData()
                }
                
            }catch{
            
            }
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return motet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "motiCell") as! MotiCellViewController
        
        let motiPerCell:Moti = motet[indexPath.row]
        
        cell.lblQyteti.text = motiPerCell.qyteti + ", " + motiPerCell.shteti
        cell.lblTemperatura.text = motet[indexPath.row].konvertoNeCelsius()
        
        let ikonaURL = URL.init(string: motiPerCell.ikonaURL())!
        
        cell.imgIkona.af_setImage(withURL: ikonaURL)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.updateMotin(moti: motet[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let request = NSFetchRequest <NSFetchRequestResult>(entityName: "Motet")
        
        let motiIZgjedhur = motet[indexPath.row]
        
        request.predicate = NSPredicate(format: "qyteti == %@ ", motiIZgjedhur.qyteti)
        
        do{
            
            let results = try context.fetch(request)
            for moti in results as! [NSManagedObject]{
                
                context.delete(moti)
            }
            motet.remove(at: indexPath.row)
            tableView.reloadData()
            
        }catch{
            
        }
        
        print(indexPath.row)
    }
    
    @IBAction func kthehu(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnKerko(_ sender: Any) {
      
        if(lblTeskti.text != ""){
            
            let params:[String:String] = ["q":lblTeskti.text!, "appid":API_KEY]
            
            merrKohen(params: params)
            print("Test2")
            
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
                
                //ruaj te dhenat ne CoreData
                let motiIRi = NSEntityDescription.insertNewObject(forEntityName: "Motet", into: self.context)
                motiIRi.setValue(ikona, forKey: "ikona")
                motiIRi.setValue(emriIQyteti, forKey: "qyteti")
                motiIRi.setValue(emriIShtetit, forKey: "shteti")
                motiIRi.setValue(temperatura, forKey: "temperatura")
                
                do{
                    try self.context.save()
                }catch{
                    print("Gabim gjate ruajtjes se te dhenave ne CoreData")
                }
                
                self.motet.append(moti)
                self.tableView.reloadData()
                print(self.motet)
                
            }else{
                
                print("Gabim gjate lidhjes me API")
            }
            
        }
    }
}
