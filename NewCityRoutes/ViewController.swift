//
//  ViewController.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/25/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import GoogleMaps
var justOnce = true

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var crosshair: UIImageView!
    @IBOutlet var busButton: UIView!
    @IBOutlet var trolleybusButton: UIView!
    @IBOutlet var tramButton: UIView!
    @IBOutlet var viewForTransportButtons: ViewForTransportButtons!
    @IBOutlet var myMapView: CreateMapView! {
        didSet {
            myMapView.createMap(view: myMapView)
        }
    }
    var json = Json()
    
    //MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerSettingsBundle()
        
        //Notification for language changes in Settings
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification , object: nil)
        
        json.readJson()
        
        //Assigning tapGesture to buttons in viewForTransportButtons
        for view in viewForTransportButtons.subviews {
            if view is UIButton {
                viewForTransportButtons.setShadow(view: view)
            } else {
                viewForTransportButtons.setShadow(view: view)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
                view.addGestureRecognizer(tapGesture)
            }
        }
        myMapView.bringSubview(toFront: crosshair)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayFromDefaults()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let defaults = UserDefaults.standard
        if (defaults.value(forKey: "launchedBefore")) == nil{
            let alert = UIAlertController(title: "Choose your preferred language", message: "You can modify your selection later, in Settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cyrillic", style: .default, handler: {_ in
                defaults.set("cyrillic", forKey: "language")
            }))
            alert.addAction(UIAlertAction(title: "Latin", style: .default, handler: {_ in
                defaults.set("latin", forKey: "language")
            }))
            
            present(alert, animated: true, completion: nil)
            defaults.set(true, forKey: "launchedBefore")
        }
    }
    
    //MARK: Gesture Recognizer
    
    func tap(sender: UITapGestureRecognizer) {
        if let view = sender.view {
            //Izvlaci identifier string iz odabranog dugmeta na pocetnom view i prosledjuje u funkciju
            UIView.animate(withDuration: 0.2, animations: {_ in
                view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                view.layer.shadowOffset = CGSize(width: -10, height: 10)
                //view.clipsToBounds = true
                
            }, completion: {_ in
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
                view.layer.shadowOffset = CGSize(width: -5, height: 5)
                //view.clipsToBounds = false
                
                self.viewForTransportButtons.selectedTransports(view: self ,sender: view.accessibilityIdentifier!)
            })
        }
    }
    
    //MARK: UserDefaults helper methods
    
    func defaultsChanged() {
        updateDisplayFromDefaults()
    }
    
    func registerSettingsBundle() {
        let appDefaults = [String: Any]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    func updateDisplayFromDefaults() {
        let defaults = UserDefaults.standard
        if let languageNotNil = defaults.value(forKey: "language") as? String {
            language = languageNotNil
        }
    }
    
    //MARK: TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(recentSearches.count)
        return recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomDetailCell
        let labelText = "Both directions available"
        cell.customCellImageView.image = UIImage(named: recentSearches[indexPath.row].route)
        cell.lineNumber.text = recentSearches[indexPath.row].ref
        
        if language == "latin" {
            cell.direction.text = labelText
        } else {
            cell.direction.text = labelText
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Searches"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailTableViewController
        self.present(controller, animated: true, completion: nil)
        controller.lineRoutes = recentSearches[indexPath.row].routes
    }
    
}

