//
//  ViewForTransportButtons.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/25/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class ViewForTransportButtons: UIView {
    
    enum Transport {
        case Bus(String)
        case Tram(String)
        case Trolleybus(String)
    }
    
    var transports = ["bus": Transport.Bus("bus"),
                      "tram": Transport.Tram("tram"),
                      "trolleybus": Transport.Trolleybus("trolleybus")
    ]
    
    func selectedTransports(view: UIViewController, sender: String) {
        if let transport = transports[sender] {
            switch transport {
            case .Bus(let value):
                instantiateView(view: view, string: value)
            case .Tram(let value):
                instantiateView(view: view, string: value)
            case .Trolleybus(let value):
                instantiateView(view: view, string: value)
            }
        }
    }
    
    func setShadow(view: UIView) {
        //view.layer.cornerRadius = view.frame.width / 2
        view.layer.shadowOpacity = 1
        view.layer.masksToBounds = false
        view.clipsToBounds = false
        view.layer.shadowOffset = CGSize(width: -5, height: 5)
        view.layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    func instantiateView(view: UIViewController, string: String) {
        let array = Json.sortedTransport(route: string)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FirstTableViewController") as! FirstTableViewController
        let navController = UINavigationController(rootViewController: controller)
        view.present(navController, animated: true, completion: nil)
        
        var typeOfRoute: String = ""
        if language == "latin" {
            if string == "tram" {
                typeOfRoute = string + "s"
            } else {
                typeOfRoute = string + "es"
            }
            controller.title = "List of \(typeOfRoute)"
        } else {
            var i = string
            if string == "bus" {
                i = "аутобуса"
            } else if string == "tram" {
                i = "трамваја"
            } else if string == "trolleybus" {
                i = "тролејбуса"
            }
            typeOfRoute = i
            
            controller.title = "Списак \(typeOfRoute)"
            controller.navigationController?.navigationBar.tintColor = .white
            controller.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
            controller.navigationController?.navigationBar.transparentNavigationBar()
        }
        controller.selectedTransport = array
        controller.backButton.title = language == "latin" ? "Back" : "Назад"
        controller.delegate = view as! InitialViewController
        
        
    }
    
    
    
}
