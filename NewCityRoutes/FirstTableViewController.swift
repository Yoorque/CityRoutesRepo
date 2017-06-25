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
    
    private func setupTableView() {
        tableView.dataSource = firstTableViewDataSource
        tableView.delegate = firstTableViewDataSource
        firstTableViewDataSource?.delegate = self
        tableView.reloadData()
    }

}

extension FirstTableViewController: InstantiateDVCDelegate {
    func instantiateViewController(routes: [Relations], route: Routes, transport: String, ref: String) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "DetailTableViewController") as! DetailTableViewController
        
        delegate?.recentSearchWasSaved(route: route)
        
        let navController = UINavigationController(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
        
        controller.detailTableViewDataSource = DetailTableViewDataSource(lineRoutes: routes)
        
        if language == "latin" {
            let titleText = "Selected \(transport) is: \(ref)"
            controller.title = titleText
            
        } else {
            var i = ""
            if transport == "bus" {
                i = "аутобус"
            } else if transport == "tram" {
                i = "трамвај"
            } else if transport == "trolleybus" {
                i = "тролејбус"
            }
            
            let titleText = "Одабрани \(i) је: \(ref)"
            controller.title = titleText
        }
        controller.backButton.title = language == "latin" ? "Back" : "Назад"
    }
}
