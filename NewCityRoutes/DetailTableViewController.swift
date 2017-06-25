//
//  DetailViewController.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/26/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

protocol DetailTableViewDelegate: NSObjectProtocol {
    func drawLine(route: Relations)
}

class DetailTableViewController: UIViewController, UITableViewDelegate {
    @IBOutlet var backButton: UIBarButtonItem!
    
    let blurClass = BlurEffect()
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var detailMapView: CreateMapView! {
        didSet {
            detailMapView.createMap(view: detailMapView)
        }
    }
    @IBOutlet var tableView: UITableView!
    @IBAction func backBarButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
}

extension DetailTableViewController: DetailTableViewDelegate {
    func drawLine(route: Relations) {
        detailMapView.drawLineMarkers(route: route)
        detailMapView.drawLinePolylines(route: route)
    }
}
