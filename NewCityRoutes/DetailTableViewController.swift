//
//  DetailViewController.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/26/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import GoogleMaps

protocol DetailTableViewDelegate: NSObjectProtocol {
    func drawLine(route: Relations)
}

class DetailTableViewController: UIViewController, UITableViewDelegate, AlertDelegate {
    @IBOutlet var backButton: UIBarButtonItem!
    
    let blurClass = BlurEffect()
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var detailMapView: CreateMapView! {
        didSet {
            detailMapView.createMap(view: detailMapView)
            detailMapView.alertDelegate = self
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func backBarButton(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    var detailTableViewDataSource: DetailTableViewDataSource?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        blurClass.blurTheBackgound(view: backgroundImageView)
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = detailTableViewDataSource
        tableView.delegate = detailTableViewDataSource
        detailTableViewDataSource?.delegate = self
        tableView.reloadData()
    }
    
    func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
}

extension DetailTableViewController: DetailTableViewDelegate {
    func drawLine(route: Relations) {
        detailMapView.drawLineMarkers(route: route)
        detailMapView.drawLinePolylines(route: route)
    }
}
