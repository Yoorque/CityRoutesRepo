//
//  RecentSearchDataSource.swift
//  NewCityRoutes
//
//  Created by Marko Tribl on 6/25/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import Foundation
import UIKit

class RecentSearchDataSource: NSObject {
    
    var recentSearches: [Routes]
    
    weak var delegate: FirstTableViewControllerDelegate?
    weak var recentSearchDelegate: InstantiateVCDelegate?
    
    init(recentSearches: [Routes]) {
        self.recentSearches = recentSearches
    }
    
    func insertRoute(route: Routes) {
        recentSearches.insert(route, at: 0)
    }
    
    func removeRoute(route: Routes) {
        recentSearches.remove(at: recentSearches.index(where: {$0 == route})!)
    }
}

extension RecentSearchDataSource: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailTableViewCell
        let index = indexPath.row
        let route = recentSearches[index]
        let transport = recentSearches[index].route
        cell.model = DetailTableViewCell.Model(route: route, transport: transport)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        headerLabel.layer.borderWidth = 2
        headerLabel.layer.cornerRadius = 15
        headerLabel.text = language == "latin" ? "Recent Searches" : "Последње претраге"
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center
        headerLabel.backgroundColor = .clear
        headerLabel.autoresizingMask = .flexibleWidth
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(headerLabel)
        headerLabel.leftAnchor.constraint(equalTo: tableView.leftAnchor, constant: 3).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: tableView.rightAnchor, constant: -3).isActive = true
        headerLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 1).isActive = true
        headerLabel.widthAnchor.constraint(equalToConstant: tableView.frame.width - 6).isActive = true
        if tableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
            headerLabel.bottomAnchor.constraint(equalTo: tableView.cellForRow(at: IndexPath(row: 0, section: 0))!.topAnchor, constant: -1).isActive = true
        } else {
            headerLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        return headerLabel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        let routes = recentSearches[index].routes
        let transport = recentSearches[index].route
        let lineRef = recentSearches[index].ref
        let route = recentSearches[index]
        
        UIView.animate(withDuration: 0.2, animations: { _ in
            tableView.cellForRow(at: indexPath)?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: {_ in
            UIView.animate(withDuration: 0.2, animations: { _ in
                tableView.cellForRow(at: indexPath)?.transform = CGAffineTransform(scaleX: 1, y: 1)
            },completion: {[weak self] _ in
                
                self?.recentSearchDelegate?.instantiateViewControllerFrom(routes: routes, route: route, transport: transport, ref: lineRef)
            })
        })
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = language == "latin" ? "Delete" : "Обриши"
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: delete, handler: {_ in
            
            self.delegate?.removeRecentSearch(fromRow: indexPath.row)
        })
        return [deleteAction]
    }
    

    

}
