//
//  FirstTableViewController.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/26/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

protocol FirstTableViewControllerDelegate: class {
    func recentSearchWasSaved(route: Routes)
    func removeRecentSearch(fromRow row: Int)
}

protocol InstantiateDVCDelegate: NSObjectProtocol {
    func instantiateViewController(routes: [Relations], route: Routes, transport: String, ref: String)
}

class FirstTableViewController: UIViewController {
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    let blurClass = BlurEffect()
    @IBOutlet var backgroundImageView: UIImageView!
    
    weak var delegate: FirstTableViewControllerDelegate?
    
    var firstTableViewDataSource: FirstTableViewDataSource?
    
    @IBAction func backBarButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blurClass.blurTheBackgound(view: backgroundImageView)
        
        setupTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let indexPath = tableView.indexPathForSelectedRow else {return}
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func setupTableView() {
        tableView.dataSource = firstTableViewDataSource
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetails" else {return}
        guard let detailViewController = segue.destination as? DetailTableViewController,
              let selectedIndex = tableView.indexPathForSelectedRow?.row
            else {return}
        let routes = firstTableViewDataSource?.selectedTransport[selectedIndex].routes
        let route = firstTableViewDataSource?.selectedTransport[selectedIndex]
        let transport = firstTableViewDataSource?.selectedTransport[selectedIndex].route
        let ref = firstTableViewDataSource?.selectedTransport[selectedIndex].ref
        detailViewController.detailTableViewDataSource = DetailTableViewDataSource(lineRoutes: routes!)
//        detailViewController.setupTransportTitleWithRef(transport: transport!, ref: ref!)
        detailViewController.backButton.title = language == "latin" ? "Back" : "Назад"
        delegate?.recentSearchWasSaved(route: route!)
    }

}

