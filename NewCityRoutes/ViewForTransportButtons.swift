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
        
    func selectedTransport(view: UIViewController, sender: String) {
        if let transport = transports[sender] {
        switch transport {
        case .Bus(let value):
            print("\(value)")
            instantiateView(view: view, string: value)
        case .Tram(let value):
            print(value)
            instantiateView(view: view, string: value)
        case .Trolleybus(let value):
            print(value)
            instantiateView(view: view, string: value)
            }
        }
    }
    
    func instantiateView(view: UIViewController, string: String) {
        let array = Json.sortedTransport(route: string)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FirstTableView") as! FirstTableViewViewController
        view.present(controller, animated: true, completion: nil)
        
        controller.selectedTransport = array
    }
    
    
    
}
