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
    @IBOutlet var borderView: UIView!
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
        }
    }
    
    let recentSearchController = RecentSearchController()
    
    @IBAction func infoButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showInfo", sender: self)
    }
    
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
    
    
    //MARK: Life cycle
    
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
        setupRecentSearch()
    }
    
    private func setupRecentSearch() {
        recentSearches = recentSearchController.savedRoutes
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
    
    //MARK: Helper methods
    
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
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailTableViewCell
        let labelText = language == "latin" ? "Both directions available" : "Оба смера"
        cell.borderView.layer.borderColor = UIColor.color(forTransport: recentSearches[indexPath.row].route).cgColor
        cell.borderView.backgroundColor = UIColor.color(forTransport: recentSearches[indexPath.row].route).withAlphaComponent(0.1)
        cell.customCellImageView.image = UIImage(named: recentSearches[indexPath.row].route)
        cell.lineNumber.text = recentSearches[indexPath.row].ref
        cell.lineNumber.textColor = UIColor.color(forTransport: recentSearches[indexPath.row].route)
        cell.direction.text = labelText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        headerLabel.layer.borderWidth = 2
        headerLabel.layer.cornerRadius = 15
        headerLabel.text = language == "latin" ? "Recent Searches" : "Последње претраге"
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center
        headerLabel.backgroundColor = .clear
        headerLabel.autoresizingMask = .flexibleWidth
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        
        headerLabel.leftAnchor.constraint(equalTo: tableView.leftAnchor, constant: 3).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: tableView.rightAnchor, constant: -3).isActive = true
        headerLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 1).isActive = true
        
        if tableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
            headerLabel.bottomAnchor.constraint(equalTo: tableView.cellForRow(at: IndexPath(row: 0, section: 0))!.topAnchor, constant: -1).isActive = true
        } else {
            headerLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        return headerLabel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.2, animations: { _ in
            tableView.cellForRow(at: indexPath)?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: {_ in
            UIView.animate(withDuration: 0.2, animations: { _ in
                tableView.cellForRow(at: indexPath)?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { _ in
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailTableViewController") as! DetailTableViewController
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
                controller.backButton.title = language == "latin" ? "Back" : "Назад"
                self.recentSearchWasSaved(route: recentSearches[indexPath.row])
            })
        })
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = language == "latin" ? "Delete" : "Обриши"
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: delete, handler: {_ in
            
            self.removeRecentSearch(fromRow: indexPath.row)
        })
        return [deleteAction]
    }
}

//MARK: Colors

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
        if !recentSearches.contains(route) {
            recentSearches.insert(route, at: 0)
        } else {
            recentSearches.remove(at: recentSearches.index(where: {$0 == route})!)
            recentSearches.insert(route, at: 0)
            
        }
        removeExtraCells()
        recentSearchController.savedRoutes = recentSearches
        tableView.reloadData()
    }
    
    func removeRecentSearch(fromRow row: Int) {
        recentSearches.remove(at: row)
        recentSearchController.savedRoutes = recentSearches
        tableView.reloadData()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: language == "latin" ? "Settings" : "Подешавања", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                })
            }
        }
        let cancelAction = UIAlertAction(title: language == "latin" ? "Cancel" : "Откажи", style: .default, handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}


