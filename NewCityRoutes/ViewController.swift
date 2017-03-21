//
//  ViewController.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/25/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import GoogleMaps
var justOnce = true

class ViewController: UIViewController {
   
    @IBOutlet var busButton: UIView!
    @IBOutlet var trolleybusButton: UIView!
    @IBOutlet var tramButton: UIView!
    @IBOutlet var viewForTransportButtons: ViewForTransportButtons!
    @IBOutlet var myMapView: CreateMapView!
    
    let mapCreation = CreateMapView()
    
    var json = Json()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerSettingsBundle()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification , object: nil)
        
        mapCreation.createMap(view: myMapView, location: mapCreation.currentLocation)
        json.readJson()
        
        for view in viewForTransportButtons.subviews {
            if view is UIButton {
                viewForTransportButtons.setShadow(view: view)
            } else {
            viewForTransportButtons.setShadow(view: view)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
            view.addGestureRecognizer(tapGesture)
        }
        }
    }
    func defaultsChanged() {
        updateDisplayFromDefaults()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapCreation.createMap(view: myMapView, location: mapCreation.currentLocation)
        mapCreation.markStation()
        updateDisplayFromDefaults()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let defaults = UserDefaults.standard
        
        if (defaults.value(forKey: "launchedBefore")) == nil{
            let alert = UIAlertController(title: "Choose your preferred language", message: "You can modify your selection later, in Settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cyrillic", style: .default, handler: {_ in
                defaults.set("cyrillic", forKey: "language")
            }))
            alert.addAction(UIAlertAction(title: "Latin", style: .default, handler: {_ in
                defaults.set("latin", forKey: "language")
            }))
            
            present(alert, animated: true, completion: nil)
            defaults.set(true, forKey: "launchedBefore")
        }
    }
    
    func tap(sender: UITapGestureRecognizer) {
        if let view = sender.view {
            //Izvlaci identifier string iz odabranog dugmeta na pocetnom view i prosledjuje u funkciju
            
            UIView.animate(withDuration: 0.2, animations: {_ in
                view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                view.layer.shadowOffset = CGSize(width: -10, height: 10)
                //view.clipsToBounds = true
                
            }, completion: {_ in
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
                view.layer.shadowOffset = CGSize(width: -5, height: 5)
                //view.clipsToBounds = false
                
            self.viewForTransportButtons.selectedTransport(view: self ,sender: view.accessibilityIdentifier!)
            })
        }
    }
    
    func registerSettingsBundle() {
        let appDefaults = [String: Any]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    func updateDisplayFromDefaults() {
        let defaults = UserDefaults.standard
        if let languageNotNil = defaults.value(forKey: "language") as? String {
            language = languageNotNil
        }
    }
}

