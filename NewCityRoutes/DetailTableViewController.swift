//
//  DetailViewController.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/26/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class DetailTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var backButton: UIBarButtonItem!
    
    var lineRoutes = [Relations]()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        blurClass.blurTheBackgound(view: backgroundImageView)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.transparentNavigationBar()
        
        backButton.title = language == "latin" ? "Back" : "Назад"
    }
    
    //MARK: TableView Delegates
    
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
        
        cell.direction.text = language == "latin" ? "\(lineRoutes[indexPath.row].reltags.fromSrLatn!) - \(lineRoutes[indexPath.row].reltags.toSrLatn!)" : "\(lineRoutes[indexPath.row].reltags.from!) - \(lineRoutes[indexPath.row].reltags.to!)"
        
        cell.lineNumber.text = lineRoutes[indexPath.row].reltags.reltagRef
        cell.customCellImageView.image = UIImage(named: lineRoutes[indexPath.row].reltags.route)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        detailMapView.drawLineMarkers(route: lineRoutes[indexPath.row])
        detailMapView.drawLinePolylines(route: lineRoutes[indexPath.row])
        
        let selectedRow = tableView.cellForRow(at: indexPath) as! DetailTableViewCell
        selectedRow.contentView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0.10, blue: 0.80, alpha: 0.5)
        
    }
}
