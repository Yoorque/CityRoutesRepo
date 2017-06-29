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

protocol InstantiateVCDelegate: NSObjectProtocol {
    func instantiateViewControllerFrom(routes: [Relations], route: Routes, transport: String, ref: String)
}

class InitialViewController: UIViewController {
    
    var tutView = UIImageView()
    var button = UIButton()
    
    @IBOutlet var infoButton: UIBarButtonItem!
    @IBOutlet var languageButton: UIBarButtonItem!
    var blurClass = BlurEffect()
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
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
            myMapView.createCrosshair(view: myMapView)
            myMapView.alertDelegate = self
            myMapView.activityDelegate = self
        }
    }
    var activityIndicator = UIActivityIndicatorView()
    let recentSearchController = RecentSearchController()
    var recentSearchDataSource: RecentSearchDataSource?
    
    @IBAction func languageButton(_ sender: UIBarButtonItem) {
        var message: String {
            return language == "latin" ? "Choose your preffered language" : "Одаберите жељени језик"
        }
        var title: String {
            return language == "latin" ? "Language" : "Језик"
        }
        var titleCancel: String {
            return language == "latin" ? "Cancel" : "Откажи"
        }
        let actionsSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actionsSheet.addAction(UIAlertAction(title: "English", style: .default, handler: {_ in
            language = "latin"
            self.reloadFor(language: language)
        }))
        
        actionsSheet.addAction(UIAlertAction(title: "Српски", style: .default, handler: {_ in
            language = "cyrillic"
            self.reloadFor(language: language)
        }))
        
        actionsSheet.addAction(UIAlertAction(title: titleCancel, style: .cancel, handler: nil))
        present(actionsSheet, animated: true)
    }
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerSettingsBundle()
        blurClass.blurTheBackgound(view: backgroundImageView)
        
        //Notification for language changes in Settings
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguageFromDefaults), name: UserDefaults.didChangeNotification , object: nil)
        
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
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.leftBarButtonItems?.append(barButton)
    }
    
    private func setupRecentSearch() {
        recentSearchDataSource = RecentSearchDataSource(recentSearches: recentSearchController.savedRoutes)
        recentSearchDataSource?.delegate = self
        recentSearchDataSource?.recentSearchDelegate = self
        tableView.dataSource = recentSearchDataSource
        tableView.delegate = recentSearchDataSource
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLanguageFromDefaults()
        setTransportButtonLabels()
        if currentReachabilityStatus == .notReachable {
            let alert = UIAlertController(title: language == "latin" ? "WARNING!" : "УПОЗОРЕЊЕ!", message: language == "latin" ? "Check your internet connection!" : "Проверите интернет конекцију!", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: language == "latin" ? "Settings" : "Подешавања", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    })
                }
            }
            alert.addAction(settingsAction)
            alert.addAction(UIAlertAction(title: language == "latin" ? "Cancel" : "Откажи", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        setupRecentSearch()
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
            
            present(alert, animated: true, completion: { _ in
                self.tutorialView()
            })
            defaults.set(true, forKey: "launchedBefore")
        }
    }
    
    //MARK: - Gesture Recognizer
    
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
    
    //MARK: - UserDefaults helper methods
    
    func registerSettingsBundle() {
        let appDefaults = [String: Any]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    func saveLanguageToDefaults(string: String) {
        let defaults = UserDefaults.standard
        defaults.set(string, forKey: "language")
    }
    
    func updateLanguageFromDefaults() {
        let defaults = UserDefaults.standard
        if let languageFromDefaults = defaults.value(forKey: "language") as? String {
            language = languageFromDefaults
            infoButton.title = language == "latin" ? "Info": "Инфо"
            languageButton.title = language == "latin" ? "Language" : "Језик"
            title = language == "latin" ? "City Routes" : "Градске Руте"
        }
    }
    
    //MARK: - Helper methods
    
    func reloadFor(language: String) {
        for subview in self.myMapView.subviews {
            subview.removeFromSuperview()
        }
        self.saveLanguageToDefaults(string: language)
        self.setTransportButtonLabels()
        self.myMapView.createMap(view: self.myMapView)
        self.myMapView.createCrosshair(view: self.myMapView)
        self.tableView.reloadData()
    }
    
    func setTransportButtonLabels() {
        busTitleLabel.text = language == "latin" ? "Bus" : "Аутобус"
        tramTitleLabel.text = language == "latin" ? "Tram" : "Трамвај"
        trolleybusTitleLabel.text = language == "latin" ? "Trolleybus" : "Тролејбус"
    }
    
    func removeExtraCells() {
        while (recentSearchDataSource?.recentSearches.count)! > 3 {
            recentSearchDataSource?.recentSearches.removeLast()
        }
        tableView.reloadData()
    }
    
    func tutorialView() {
        infoButton.isEnabled = false
        languageButton.isEnabled = false
        tutView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        tutView.image = UIImage(named: "tutorial")
        tutView.contentMode = .scaleToFill
        tutView.isUserInteractionEnabled = true
        view.addSubview(tutView)
        
        button = UIButton()
        button.frame.size = CGSize(width: 150, height: 30)
        button.center = CGPoint(x: tutView.frame.width / 2, y: tutView.frame.height * 0.95)
        button.setTitle("Close the tutorial", for: .normal)
        button.addTarget(self, action: #selector(dismissTutorial), for: .touchUpInside)
        button.tintColor = UIColor.white
        view.addSubview(button)
    }
    
    func dismissTutorial(view: UIImageView) {
        tutView.removeFromSuperview()
        button.removeFromSuperview()
        infoButton.isEnabled = true
        languageButton.isEnabled = true
    }
}

//MARK: - Extensions

extension UIColor {
    @nonobjc class var busRed: UIColor {
        return UIColor(red: 1, green: 58/255, blue: 58/255, alpha: 1)
    }
    
    @nonobjc class var tramGreen: UIColor {
        return UIColor(red: 112/255, green: 193/255, blue: 106/255, alpha: 1)
    }
    
    @nonobjc class var trolleyOrange: UIColor {
        return UIColor.orange
    }
    
    class func color(forTransport transport: String) -> UIColor {
        switch transport {
        case "bus": return .busRed
        case "tram": return .tramGreen
        case "trolleybus": return .trolleyOrange
        default: return .clear
        }
    }
}

extension InitialViewController: FirstTableViewControllerDelegate, AlertDelegate {
    func recentSearchWasSaved(route: Routes) {
        if !(recentSearchDataSource?.recentSearches)!.contains(route) {
            recentSearchDataSource?.insertRoute(route: route)
        } else {
            recentSearchDataSource?.removeRoute(route: route)
            recentSearchDataSource?.insertRoute(route: route)
            
        }
        removeExtraCells()
        recentSearchController.savedRoutes = (recentSearchDataSource?.recentSearches)!
        tableView.reloadData()
    }
    
    func removeRecentSearch(fromRow row: Int) {
        recentSearchDataSource?.recentSearches.remove(at: row)
        
        recentSearchController.savedRoutes = (recentSearchDataSource?.recentSearches)!
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

extension InitialViewController: InstantiateVCDelegate, NotificationForIndicatorDelegate {
    
    func instantiateViewControllerFrom(routes: [Relations], route: Routes, transport: String, ref: String) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailTableViewController") as! DetailTableViewController
        
        controller.detailTableViewDataSource = DetailTableViewDataSource(lineRoutes: routes)
        controller.setupTransportTitleWithRef(transport: transport, ref: ref)
        controller.backButton.title = language == "latin" ? "Back" : "Назад"
        navigationController?.pushViewController(controller, animated: true)
        recentSearchWasSaved(route: route)
        
    }
    
    func isIndicatorActive(value: Bool) {
        if currentReachabilityStatus == .reachableViaWiFi {
            
            if value == true {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                title = language == "latin" ? "Calculating distance" : "Рачунам раздаљину"
            } else {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                title = language == "latin" ? "City Routes" : "Градске руте"
            }
        }
    }
}

extension UIViewController {
    func setupTransportTitleWithRef(transport: String, ref: String) {
        if language == "latin" {
            let titleText = "Selected \(transport) is: \(ref)"
            self.title = titleText
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
            self.title = titleText
        }
    }
    
    func setupTransportTitle(transport: String) {
        var typeOfRoute: String = ""
        if language == "latin" {
            if transport == "tram" {
                typeOfRoute = transport + "s"
            } else {
                typeOfRoute = transport + "es"
            }
            self.title = "List of \(typeOfRoute)"
        } else {
            var i = transport
            if transport == "bus" {
                i = "аутобуса"
            } else if transport == "tram" {
                i = "трамваја"
            } else if transport == "trolleybus" {
                i = "тролејбуса"
            }
            typeOfRoute = i
            
            self.title = "Списак \(typeOfRoute)"
        }
    }
}



