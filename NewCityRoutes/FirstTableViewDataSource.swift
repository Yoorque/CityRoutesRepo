//
//  FirstTableViewDataSource.swift
//  NewCityRoutes
//
//  Created by Marko Tribl on 6/25/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class FirstTableViewDataSource: NSObject {
    var selectedTransport: [Routes]
    
    weak var delegate: InstantiateDVCDelegate?
    
    init(selectedTransport: [Routes]) {
        self.selectedTransport = selectedTransport
    }
}

extension FirstTableViewDataSource: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTransport.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FirstTableViewCell
        let index = indexPath.row
        let route = selectedTransport[index]
        let transport = selectedTransport[index].route
        cell.model = FirstTableViewCell.Model(route: route, transport: transport)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let index = indexPath.row
        let routes = selectedTransport[index].routes
        let transport = selectedTransport[index].route
        let lineRef = selectedTransport[index].ref
        let route = selectedTransport[index]
        
        delegate?.instantiateViewController(routes: routes, route: route, transport: transport, ref: lineRef)
        
//        let controller = storyboard?.instantiateViewController(withIdentifier: "DetailTableViewController") as! DetailTableViewController
//        
//        delegate?.recentSearchWasSaved(route: selectedTransport[indexPath.row])
//        
//        let navController = UINavigationController(rootViewController: controller)
//        self.present(navController, animated: true, completion: nil)
//        
//        controller.lineRoutes = self.selectedTransport[indexPath.row].routes
//        
//        if language == "latin" {
//            let titleText = "Selected \(selectedTransport[indexPath.row].route) is: \(selectedTransport[indexPath.row].ref)"
//            controller.title = titleText
//            
//        } else {
//            var i = ""
//            if selectedTransport[indexPath.row].route == "bus" {
//                i = "аутобус"
//            } else if selectedTransport[indexPath.row].route == "tram" {
//                i = "трамвај"
//            } else if selectedTransport[indexPath.row].route == "trolleybus" {
//                i = "тролејбус"
//            }
//            
//            let titleText = "Одабрани \(i) је: \(selectedTransport[indexPath.row].ref)"
//            controller.title = titleText
//        }
//        controller.backButton.title = language == "latin" ? "Back" : "Назад"
    }

 
}
