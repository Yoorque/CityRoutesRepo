//
//  FirstTableViewController.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/26/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit



class FirstTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    var selectedTransport = [Routes]()
    let blurClass = BlurEffect()
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBAction func backBarButton(_ sender: UIBarButtonItem) {
        
        saveRecentSearches()
        dismiss(animated: true, completion: nil)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurClass.blurTheBackgound(view: backgroundImageView)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.transparentNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if language == "latin" {
            backButton.title = "Back"
        } else {
            backButton.title = "Назад"
        }
    }
    
    //MARK: TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTransport.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FirstTableViewCell
        
        cell.cellImageView.image = UIImage(named: selectedTransport[indexPath.row].route)
        cell.refNumber.text = selectedTransport[indexPath.row].ref
        if language == "latin" {
            cell.titleLabel.text = selectedTransport[indexPath.row].routes[0].reltags.fromSrLatn + "-" + selectedTransport[indexPath.row].routes[0].reltags.toSrLatn
        } else {
            cell.titleLabel.text = selectedTransport[indexPath.row].routes[0].reltags.from + "-" + selectedTransport[indexPath.row].routes[0].reltags.to
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = storyboard?.instantiateViewController(withIdentifier: "DetailTableViewController") as! DetailTableViewController
        
        if !recentSearches.contains(selectedTransport[indexPath.row]) {
            recentSearches.insert(selectedTransport[indexPath.row], at: 0)
        }
        
        let navController = UINavigationController(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
        
        controller.lineRoutes = self.selectedTransport[indexPath.row].routes
        
        if language == "latin" {
        let titleText = "Selected \(selectedTransport[indexPath.row].route) is: \(selectedTransport[indexPath.row].ref)"
            controller.title = titleText

        } else {
            var i = ""
            if selectedTransport[indexPath.row].route == "bus" {
                i = "аутобус"
            } else if selectedTransport[indexPath.row].route == "tram" {
                i = "трамвај"
            } else if selectedTransport[indexPath.row].route == "trolleybus" {
                i = "тролејбус"
            }
            
        let titleText = "Одабрани \(i) је: \(selectedTransport[indexPath.row].ref)"
            controller.title = titleText
        }
        
    }
}
