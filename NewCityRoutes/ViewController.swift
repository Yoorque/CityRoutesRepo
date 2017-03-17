//
//  ViewController.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/25/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import GoogleMaps

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
        mapCreation.createMap(view: myMapView, location: mapCreation.currentLocation)
        json.readJson()
        
        for view in viewForTransportButtons.subviews {
            viewForTransportButtons.setShadow(view: view)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
            view.addGestureRecognizer(tapGesture)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapCreation.createMap(view: myMapView, location: mapCreation.currentLocation)
        mapCreation.markStation()
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
    
}

