//
//  DetailViewController.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/26/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var lineRoutes = [Relations]()
    
    @IBOutlet var detailMapView: CreateMapView! {
        didSet {
            detailMapView.createMap(view: detailMapView, location: detailMapView.currentLocation)
        }
    }
    @IBOutlet var tableView: UITableView!


@IBAction func backButton(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lineRoutes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = lineRoutes[indexPath.row].reltags.relName
        cell.imageView?.image = UIImage(named: lineRoutes[indexPath.row].reltags.route)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        detailMapView.drawLineMarkers(route: lineRoutes[indexPath.row])
        detailMapView.drawLinePolylines(route: lineRoutes[indexPath.row])
        let selectedRow = tableView.cellForRow(at: indexPath)
       selectedRow?.contentView.backgroundColor = .green
    }
}
