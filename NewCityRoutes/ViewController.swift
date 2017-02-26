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
        mapCreation.createMap(view: myMapView)
        json.readJson()
        
        for view in viewForTransportButtons.subviews {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
            view.addGestureRecognizer(tapGesture)
        }
        
    }

    func tap(sender: UITapGestureRecognizer) {
        if let view = sender.view {
            viewForTransportButtons.selectedTransport(view: self ,sender: view.accessibilityIdentifier!)
        }
    }
    
}

