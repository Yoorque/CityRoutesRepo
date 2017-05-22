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

class InitialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var languageButton: UIBarButtonItem!
    var blurClass = BlurEffect()
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var crosshair: UIImageView!
    @IBOutlet var busTitleLabel: UILabel!
    @IBOutlet var busButton: UIView!
    @IBOutlet var tramTitleLabel: UILabel!
    @IBOutlet var trolleybusTitleLabel: UILabel!
    @IBOutlet var trolleybusButton: UIView!
    @IBOutlet var tramButton: UIView!
    @IBOutlet var viewForTransportButtons: ViewForTransportButtons!
    @IBOutlet var myMapView: CreateMapView! {
        didSet {
            myMapView.createMap(view: myMapView)
        }
    }
    
    @IBAction func languageButton(_ sender: UIBarButtonItem) {
        var lang = ""
        let actionsSheet = UIAlertController(title: "Language", message: "Choose your preffered language", preferredStyle: .actionSheet)
        actionsSheet.addAction(UIAlertAction(title: "English", style: .default, handler: {_ in
            language = "latin"
            lang = language
            
            self.reloadFor(language: lang)
        }))
        
        actionsSheet.addAction(UIAlertAction(title: "Српски", style: .default, handler: {_ in
            language = "cyrillic"
            lang = language
            
            self.reloadFor(language: lang)
        }))
        
        present(actionsSheet, animated: true)
    }
    
//    var json = Json()
    
    func reloadFor(language: String) {
        for subview in self.myMapView.subviews {
            subview.removeFromSuperview()
        }
        self.saveLanguageToDefaults(string: language)
        self.setTransportButtonLabels()
        self.myMapView.createMap(view: self.myMapView)
        self.tableView.reloadData()
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerSettingsBundle()
        loadRecentSearches()
        
        blurClass.blurTheBackgound(view: backgroundImageView)
        //Notification for language changes in Settings
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguageFromDefaults), name: UserDefaults.didChangeNotification , object: nil)
        
//        json.readJson()
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLanguageFromDefaults()
        removeExtraCells()
        // setTransportButtonLabels()
        tableView.reloadData()
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    func saveLanguageToDefaults(string: String) {
        let defaults = UserDefaults.standard
        defaults.set(string, forKey: "language")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let defaults = UserDefaults.standard
        if (defaults.value(forKey: "launchedBefore")) == nil{
            let alert = UIAlertController(title: "Choose your preferred language", message: "You can modify your selection later by tapping on Language button in the upper right corner", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Српски", style: .default, handler: {_ in
                defaults.set("cyrillic", forKey: "language")
            }))
            alert.addAction(UIAlertAction(title: "English", style: .default, handler: {_ in
                defaults.set("latin", forKey: "language")
            }))
            
            present(alert, animated: true, completion: nil)
            defaults.set(true, forKey: "launchedBefore")
        }
    }
    
    func setTransportButtonLabels() {
        if language == "latin" {
        busTitleLabel.text = "Bus"
        tramTitleLabel.text = "Tram"
        trolleybusTitleLabel.text = "Trolleybus"
        } else {
            busTitleLabel.text = "Аутобус"
            tramTitleLabel.text = "Трамвај"
            trolleybusTitleLabel.text = "Тролејбус"
        }
    }
    
    //MARK: Gesture Recognizer
    
    func tap(sender: UITapGestureRecognizer) {
        if let view = sender.view {
            //Izvlaci identifier string iz odabranog dugmeta na pocetnom view i prosledjuje u funkciju
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {_ in
                view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                view.layer.shadowOffset = CGSize(width: -10, height: 10)
                //view.clipsToBounds = true
                
            }, completion: {_ in
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { _ in
                    view.transform = CGAffineTransform(scaleX: 1, y: 1)
                    view.layer.shadowOffset = CGSize(width: -5, height: 5)
                    //view.clipsToBounds = false
                    
                    self.viewForTransportButtons.selectedTransports(view: self ,sender: view.accessibilityIdentifier!)
                })
            })
        }
    }
    
    //MARK: UserDefaults helper methods
    
    func registerSettingsBundle() {
        let appDefaults = [String: Any]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    func updateLanguageFromDefaults() {
        let defaults = UserDefaults.standard
        if let languageFromDefaults = defaults.value(forKey: "language") as? String {
            language = languageFromDefaults
            if language == "latin" {
                languageButton.title = "Language"
            } else {
                languageButton.title = "Језик"
            }
        }
    }
    
    //MARK: TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }
    
    func removeExtraCells() {
        while recentSearches.count > 3 {
            recentSearches.removeLast()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailTableViewCell
        
        let labelText = "Both directions available"
        let labelTextSr = "Оба смера"
        cell.customCellImageView.image = UIImage(named: recentSearches[indexPath.row].route)
        cell.lineNumber.text = recentSearches[indexPath.row].ref
        
        if language == "latin" {
            cell.direction.text = labelText
        } else {
            cell.direction.text = labelTextSr
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Recent Searches"
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
    
        headerLabel.layer.borderColor = UIColor.white.cgColor
        headerLabel.layer.borderWidth = 1
        if language == "latin" {
        headerLabel.text = "Recent Searches"
        } else {
            headerLabel.text = "Последње претраге"
        }
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center
        headerLabel.backgroundColor = .clear
        headerLabel.autoresizingMask = .flexibleWidth
        view.addSubview(headerLabel)
        return headerLabel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "DetailTableViewController") as! DetailTableViewController
        let navController = UINavigationController(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
        
        controller.lineRoutes = recentSearches[indexPath.row].routes
        if language == "latin" {
        let titleText = "Selected \(recentSearches[indexPath.row].route) is: \(recentSearches[indexPath.row].ref)"
            controller.title = titleText
        } else {
            var i = ""
            if recentSearches[indexPath.row].route == "bus" {
                i = "аутобус"
            } else if recentSearches[indexPath.row].route == "tram" {
                i = "трамвај"
            } else if recentSearches[indexPath.row].route == "trolleybus" {
                i = "тролејбус"
            }
            
            let titleText = "Одабрани \(i) је: \(recentSearches[indexPath.row].ref)"
            controller.title = titleText
        }
    
    }
    
}

extension UINavigationBar {
    func transparentNavigationBar() {
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
        self.backgroundColor = UIColor.clear
    }
}

