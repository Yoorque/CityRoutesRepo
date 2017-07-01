//
//  DetailTableViewDataSource.swift
//  NewCityRoutes
//
//  Created by Marko Tribl on 6/25/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class DetailTableViewDataSource: NSObject {
    
    var lineRoutes: [Relations]
    
    weak var delegate: DetailTableViewDelegate?
    
    init(lineRoutes: [Relations]) {
        self.lineRoutes = lineRoutes
    }
}

extension DetailTableViewDataSource: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if lineRoutes[0].rel == lineRoutes[1].rel {
            tableView.rowHeight = 88
            return 1
        } else {
            return lineRoutes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailTableViewCell
        let index = indexPath.row
        let relation = lineRoutes[index]
        let transport = lineRoutes[index].reltags.route
        cell.modelRelation = DetailTableViewCell.ModelRelation(relation: relation, transport: transport!)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let route = lineRoutes[index]
        delegate?.drawLine(route: route)
        
        let selectedRow = tableView.cellForRow(at: indexPath) as! DetailTableViewCell
        selectedRow.selectionImage.image = UIImage(named: "yes")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedRow = tableView.cellForRow(at: indexPath) as! DetailTableViewCell
        selectedRow.selectionImage.image = UIImage()
    }
}
