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

extension FirstTableViewDataSource: UITableViewDataSource {
    
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
    
    
}
