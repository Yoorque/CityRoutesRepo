//
//  CreateMapView.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/25/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import GoogleMaps

protocol AlertDelegate: class {
    func showAlert(title: String, message: String, actions: [UIAlertAction])
}

protocol NotificationForIndicatorDelegate: class {
    func isIndicatorActive(value: Bool)
}

func + (left: NSMutableAttributedString, right: NSMutableAttributedString) -> NSMutableAttributedString {
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}

class CreateMapView: UIView, GMSMapViewDelegate, CLLocationManagerDelegate {
    enum MapViewSource: Int {
        case Main = 1
        case Detail = 2
    }
    var crosshair = UIImageView()
    var currentMarkerIcon = UIImageView()
    var mapView: GMSMapView!
    var detailMarker: GMSMarker! {
        didSet {
            detailMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        }
    }
    
    let paragraph = NSMutableParagraphStyle()
    var drivingCoords = [CLLocationCoordinate2D]()
    var alertCounter = 0
    weak var alertDelegate: AlertDelegate?
    
    var initialVC = InitialViewController()
    var walkPolyLineArray = [GMSPolyline]()
    var drivePolyLineArray = [GMSPolyline]()
    var currentZoomLevel: Float!
    var currentBearing: CLLocationDirection!
    var currentAngle: Double!
    var currentSelectedMarkers = [GMSMarker]()
    var circle: GMSCircle?
    var lines = NSMutableAttributedString()
    var viewController = InitialViewController()
    var selectedFeature = [Feature]()
    var selectedRelation = [Relations]()
    var notificationLabel = UILabel()
    let locationManager = CLLocationManager()
    var nearestLocation = CalculateNearestStation()
    let simPosition = CLLocationCoordinate2D(latitude: 44.818611, longitude: 20.468056)
    var currentLocation: CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }
    
    weak var activityDelegate: NotificationForIndicatorDelegate?
    
    
    //MARK: - MapView Helper Methods
    
    func createMap(view: UIView) {
        // Testing on a device
        if let currentLocation = currentLocation {
            let camera = GMSCameraPosition.camera(withTarget: currentLocation, zoom: 15)
            mapView = GMSMapView.map(withFrame: CGRect(x:0, y: 0, width: view.bounds.width, height: view.bounds.height), camera: camera)
        } else {
        mapView = GMSMapView(frame: CGRect(x:0, y: 0, width: view.bounds.width, height: view.bounds.height))
        }
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        mapView.delegate = self
        view.addSubview(mapView)
        
        createNotificationLabel(view: view)
        
        notificationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        notificationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        notificationLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        notificationLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        notificationLabel.text = language == "latin" ? "Tap the station marker to see details" : "Кликните маркер да видите детаље"
        labelAnimate(string: notificationLabel.text!)
    }
    
    func createCrosshair(view: UIView) {
        crosshair = UIImageView(image: UIImage(named: "crosshair"))
        view.addSubview(crosshair)
        
        crosshair.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        crosshair.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        crosshair.widthAnchor.constraint(equalToConstant: 30).isActive = true
        crosshair.heightAnchor.constraint(equalToConstant: 30).isActive = true
        crosshair.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func createNotificationLabel(view: UIView) {
        
        notificationLabel.textAlignment = .center
        notificationLabel.textColor = .red
        notificationLabel.adjustsFontSizeToFitWidth = true
        
        notificationLabel.autoresizingMask = .flexibleWidth
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.font = UIFont.boldSystemFont(ofSize: 12)
        view.addSubview(notificationLabel)
    }
    
    func labelAnimate(string: String) {
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            self?.notificationLabel.text = string
            self?.notificationLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }, completion: {_ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.notificationLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
        })
    }
    
    //Izvlaci i filtrira odabranu vrstu prevoza i poziva se iz DetailViewController-a
    
    func drawLineMarkers(route: Relations) {
        mapView.clear()
        
        notificationLabel.text = language == "latin" ? "Tap the station marker to see details" : "Кликните маркер да видите детаље"
        
        labelAnimate(string: notificationLabel.text!)
        for feature in featureArray {
            for relation in feature.property.relations {
                // print(relation.reltags.route, route.reltags.route)
                if relation.reltags.route == route.reltags.route {
                    if relation.rel == route.rel {
                        if feature.property.highway == "bus_stop" || feature.property.railway == "tram_stop" || feature.property.amenity == "bus_station"{
                            for coord in feature.geometry.coordinates {
                                
                                setCoords(coord: coord, feature: feature, relation: route)
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func drawLinePolylines(route: Relations) {
        
        for feature in featureArray {
            for relation in feature.property.relations {
                if relation.rel == route.rel {
                    let path = GMSMutablePath()
                    if feature.geometry.type == "LineString" {
                        for coord in feature.geometry.coordinates {
                            let lat = coord.lat
                            let lon = coord.lon
                            
                            let coords = CLLocationCoordinate2DMake(lat, lon)
                            path.add(coords)
                            let polyline = GMSPolyline(path: path)
                            polyline.strokeColor = .red
                            polyline.strokeWidth = 2
                            polyline.map = mapView
                        }
                    }
                }
            }
        }
    }
    
    // Iscrtava rutu i markere u zavisnosti od odabrane u drawTransportLines() odakle se i poziva
    
    
    private func setCoords(coord: Coordinates, feature: Feature, relation: Relations) {
        lines = NSMutableAttributedString()
        var dictionary = [String: Any]()
        
        selectedFeature.append(feature)
        selectedRelation.append(relation)
        
        let coords = CLLocationCoordinate2DMake(coord.lat, coord.lon)
        
        let camera = GMSCameraPosition(target: coords, zoom: 13, bearing: 0, viewingAngle: 0)
        mapView.camera = camera
        
        detailMarker = GMSMarker(position:coords)
        detailMarker.icon = UIImage(named: "whiteRedCircle")
        detailMarker.map = mapView
        
        var relationArray = [Relations]()
        
        for rela in feature.property.relations {
            if rela.reltags.reltagRef != relation.reltags.reltagRef {
                relationArray.append(rela)
            }
        }
        
        let sortedRelationArray = relationArray.sorted{$0.reltags.reltagRef.localizedStandardCompare($1.reltags.reltagRef) == .orderedAscending}
        
        paragraph.lineSpacing = 2
        
        lines = sortedRelationArray.map{NSMutableAttributedString(string: $0.reltags.reltagRef, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.backgroundColor: UIColor.color(forTransport: $0.reltags.route), NSAttributedStringKey.paragraphStyle: paragraph])}.joined(separator: " ")
        
        relationArray = []

        let covered = feature.property.covered != "" ? feature.property.covered : feature.property.shelter != "" ? feature.property.shelter : "no"
        let wheelchair = feature.property.wheelchair != "" ? feature.property.wheelchair : "no"
        let code = feature.property.phone != "" ? feature.property.phone : feature.property.codeRef != "" ? "*011*\(feature.property.codeRef)#" : "no code"
        let stationName = language == "latin" ? feature.property.nameSrLatn : feature.property.name
        
        dictionary.updateValue(lines, forKey: "lines")
        dictionary.updateValue(covered, forKey: "covered")
        dictionary.updateValue(wheelchair, forKey: "wheelchair")
        dictionary.updateValue(code, forKey: "code")
        dictionary.updateValue(stationName, forKey: "stationName")
        dictionary.updateValue(relation.reltags.route, forKey: "route")
        dictionary.updateValue(relation.reltags.reltagRef, forKey: "selectedLine")
        
        detailMarker.userData = dictionary
    }
    
    // Calculate nearest station from user location
    
    func markStation(forPosition position: GMSCameraPosition) {
        for marker in currentSelectedMarkers {
            if marker != mapView.selectedMarker {
                marker.map = nil
            } else {
                switch currentZoomLevel {
                case 15..<17:
                    marker.icon = UIImage(named: "fullRedCircle")
                case 17...mapView.maxZoom:
                    marker.icon = UIImage(named: (marker.userData as! [String:Any])["markerImage"] as! String + "Full")
                default:
                    break
                }
            }
        }
        
        nearestLocation.calculateNearestStation(from: mapView.camera.target)
        
        var transportImageNames = Set<String>()
        var finalIconImageName = ""
        lines = NSMutableAttributedString()
        
        selectedFeature.removeAll()
        
        selectedFeature = nearestLocation.featuresForNearestStation
        var relationArray = [Relations]()
        for feature in selectedFeature {
            for relation in feature.property.relations {
                relationArray.append(relation)
                transportImageNames.insert(relation.reltags.route)
            }
            
            let sortedRelationArray = relationArray.sorted{$0.reltags.reltagRef.localizedStandardCompare($1.reltags.reltagRef) == .orderedAscending}
            paragraph.lineSpacing = 2
            
            lines = sortedRelationArray.map{NSMutableAttributedString(string: $0.reltags.reltagRef, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.backgroundColor: UIColor.color(forTransport: $0.reltags.route), NSAttributedStringKey.paragraphStyle: paragraph])}.joined(separator: " ")
            
            let lat = feature.geometry.coordinates[0].lat
            let lon = feature.geometry.coordinates[0].lon
            let pos = CLLocationCoordinate2DMake(lat, lon)
            
            detailMarker = GMSMarker(position: pos)
            detailMarker.map = mapView
            
            finalIconImageName = transportImageNames.reduce(finalIconImageName, +)
            
            switch position.zoom {
            case 15..<17:
                detailMarker.icon = UIImage(named: "redCircle")
            case 17...mapView.maxZoom:
                detailMarker.icon = UIImage(named: finalIconImageName != "" ? finalIconImageName : "ada")
        
            default:
                break
            }
            
            let stationName = language == "latin" ? feature.property.nameSrLatn : feature.property.name
            let code = feature.property.phone != "" ? feature.property.phone : feature.property.codeRef != "" ? "*011*\(feature.property.codeRef)#" : "no code"
            
            let dictionary: [String: Any] = ["lines": lines, "markerImage": finalIconImageName != "" ? finalIconImageName : "ada", "code": code, "stationName": stationName]
            detailMarker.userData = dictionary
            
            currentSelectedMarkers.append(detailMarker)
            
            lines = NSMutableAttributedString()
            transportImageNames = []
            finalIconImageName = ""
            relationArray = []
        }
    }
    
    //MARK: - InfoWindows
    
    func mainScreenMarkerInfoWindow(marker: GMSMarker) -> UIView{
        let infoWindow = Bundle.main.loadNibNamed("InitialMapInfoWindow", owner: self, options: nil)?.first as! InitialMapInfoWindow
        let markerDict = marker.userData as! [String: Any]
        
        infoWindow.otherLinesLabel.attributedText = markerDict["lines"] as? NSMutableAttributedString
        
        if infoWindow.otherLinesLabel.attributedText?.string == "" {
            infoWindow.underView.isHidden = true
        }
        
        infoWindow.distance.text = markerDict["distance"] as? String
        infoWindow.code.text = markerDict["code"] as? String
        infoWindow.stationName.text = markerDict["stationName"] as? String
        
        infoWindow.otherLinesLabel.sizeToFit()
        infoWindow.stationName.sizeToFit()
        
        infoWindow.frame.size = CGSize(width: 218, height: 5 + infoWindow.stationName.frame.height + infoWindow.stationUnderView.frame.height + 5 + infoWindow.otherLinesLabel.frame.height + (infoWindow.underView.frame.height - 25))
        
        return infoWindow
    }
    
    func detailScreenMarkerInfoWindow(marker: GMSMarker) -> UIView {
        let infoWindow = Bundle.main.loadNibNamed("DetailMapInfoWindow", owner: self, options: nil)?.first as! DetailMapInfoWindow
        
        let markerDict = marker.userData as! [String: Any]
        
        infoWindow.layer.borderWidth = 2
        infoWindow.layer.cornerRadius = 13
        infoWindow.layer.borderColor = UIColor.red.cgColor
        
        infoWindow.codeLanguageLabel.text = language == "latin" ? "Code" : "Код"
        infoWindow.coveredLanguageLabel.text = language == "latin" ? "Covered" : "Покривена"
        infoWindow.wheelchairLanguageLabel.text = language == "latin" ? "Wheelchair" : "Колица"
        infoWindow.otherLinesLanguageLabel.text = language == "latin" ? "Lines" : "Линије"
        
        infoWindow.coveredImage.image = UIImage(named: markerDict["covered"] as! String)
        infoWindow.wheelchairImage.image = UIImage(named: markerDict["wheelchair"] as! String)
        infoWindow.code.text = markerDict["code"] as? String
        infoWindow.stationName.text  = markerDict["stationName"] as? String
        
        infoWindow.otherLines.attributedText = markerDict["lines"] as? NSMutableAttributedString
        infoWindow.otherLines.lineBreakMode = .byTruncatingTail // Ovo je dodato da bi se smanjio font
        
        infoWindow.selectedLine.attributedText = NSMutableAttributedString(string: markerDict["selectedLine"] as! String, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        infoWindow.selectedLine.layer.cornerRadius = 10
        infoWindow.selectedLine.layer.masksToBounds = true
        infoWindow.selectedLine.backgroundColor = UIColor.color(forTransport: markerDict["route"] as! String)
        
        
        infoWindow.imageView.image = UIImage(named: markerDict["route"] as! String)
        
        return infoWindow
    }
    // MARK: - POLYLINES
    
    // MARK: DrivePolylines
//    func snap(coordinates: [CLLocationCoordinate2D]) {
//       
//        var coordsString = ""
//        for coord in coordinates {
//            coordsString += "\(coord.latitude),\(coord.longitude)|"
//        }
//        coordsString.remove(at: coordsString.index(before: coordsString.endIndex))
//        let snapToRoads = "https://roads.googleapis.com/v1/snapToRoads?path=\(coordsString)&interpolate=true&key=AIzaSyDrBwOZfhxn9PxoCOR18GMIaTBuDjamzRA"
//        let urlEncoding = snapToRoads.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//        
//        if let path = URL(string: urlEncoding!) {
//            do {
//                let data = try String(contentsOf: path, encoding: String.Encoding.utf8)
//                let jData = data.data(using: String.Encoding.utf8)
//                do {
//                    let json = try JSONSerialization.jsonObject(with: jData!, options: []) as! [String: Any]
//                    
//                    let snappedPoints = json["snappedPoints"] as! [[String: Any]]
//                    
//                    let polyPath = GMSMutablePath()
//                    for snappedPoint in snappedPoints {
//                    
//                        let location = snappedPoint["location"] as! [String: Any]
//                        
//                        let latitude = location["latitude"] as! CLLocationDegrees
//                        let longitude = location["longitude"] as! CLLocationDegrees
//                        
//                        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
//                        
//                        polyPath.add(coordinates)
//                        
//                    }
//                    let interpolatedPolyline = GMSPolyline(path: polyPath)
//                    interpolatedPolyline.strokeColor = UIColor.red
//                    interpolatedPolyline.strokeWidth = 2
//                    interpolatedPolyline.map = mapView
//                    drivePolyLineArray.append(interpolatedPolyline)
//                } catch {
//                    print("Bad json")
//                }
//            } catch {
//                print("Bad path")
//            }
//        }
//        
//    }
    
//    func calculateDrivingRoute(toDestination location: CLLocationCoordinate2D) {
//        clearPolylines()
//        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.currentLocation.latitude),\(self.currentLocation.longitude)&destination=\(location.latitude),\(location.longitude)&mode=driving&key=AIzaSyDrBwOZfhxn9PxoCOR18GMIaTBuDjamzRA"
//        
//        if let path = URL(string: url) {
//            do {
//                
//                let data = try String(contentsOf: path, encoding: String.Encoding.utf8)
//                let jData = data.data(using: String.Encoding.utf8)
//                do {
//                    let json = try JSONSerialization.jsonObject(with: jData!, options: []) as? [String: Any]
//                    
//                    let routes = json!["routes"] as! [[String: Any]]
//                    for route in routes {
//                        
//                        let legs = route["legs"] as! [[String: Any]]
//                        //var totalDistance = 0
//                        for leg in legs {
//                            
//                            let steps = leg["steps"] as! [[String: Any]]
//                            for step in steps {
//                                
//                                // let distance = step["distance"] as! [String:Any]
//                                //let distanceValue = distance["value"] as! Int
//                                let startLocation = step["start_location"] as! [String: Any]
//                                let endLocation = step["end_location"] as! [String: Any]
//                                
//                                let startCoords = CLLocationCoordinate2DMake(startLocation["lat"] as! CLLocationDegrees, startLocation["lng"] as! CLLocationDegrees)
//                                let endCoords = CLLocationCoordinate2DMake(endLocation["lat"] as! CLLocationDegrees, endLocation["lng"] as! CLLocationDegrees)
//                                
//                                drivingCoords.append(startCoords)
//                                drivingCoords.append(endCoords)
//                            }
//                        }
//                        
//                        snap(coordinates: drivingCoords)
//                        drivingCoords = []
//                        
//                    }
//                } catch {
//                    print("Bad json")
//                    let title = language == "latin" ? "WARNING!" : "УПОЗОРЕЊЕ!"
//                    let message = language == "latin" ? "Something went wrong with our data, but we're working on it. Please, try again later." : "Дошло је до грешке у нашим подацима, али радимо на томе. Молимо вас да покушате касније."
//                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//                    self.alertDelegate?.showAlert(title: title, message: message, actions: [action])
//                }
//            } catch {
//                print("Bad path")
//                if self.currentReachabilityStatus == .notReachable {
//                    if self.alertCounter == 0 || self.alertCounter == 5 {
//                        
//                        let title = language == "latin" ? "WARNING!" : "УПОЗОРЕЊЕ!"
//                        let message = language == "latin" ? "You need internet connection for directions to station!" : "Потребна је интернет конекција за навођење до станице!"
//                        let cancelAction = UIAlertAction(title: language == "latin" ? "Cancel" : "Откажи", style: .default, handler: nil)
//                        let settingsAction = UIAlertAction(title: language == "latin" ? "Settings" : "Подешавања", style: .default) { (_) -> Void in
//                            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
//                                return
//                            }
//                            if UIApplication.shared.canOpenURL(settingsUrl) {
//                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
//                                })
//                            }
//                        }
//                        self.alertDelegate?.showAlert(title: title, message: message, actions: [settingsAction, cancelAction])
//                        
//                    }
//                    self.alertCounter += 1
//                    if self.alertCounter == 5 {
//                        self.alertCounter = 0
//                    }
//                } else {
//                    let title = language == "latin" ? "WARNING!" : "УПОЗОРЕЊЕ!"
//                    let message = language == "latin" ? "Something went wrong with our data, but we're working on it. Please, try again later." : "Дошло је до грешке у нашим подацима, али радимо на томе. Молимо вас да покушате касније."
//                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//                    self.alertDelegate?.showAlert(title: title, message: message, actions: [action])
//                }
//            }
//        } else {
//            print("Bad url")
//            let title = language == "latin" ? "WARNING!" : "УПОЗОРЕЊЕ!"
//            let message = language == "latin" ? "Something went wrong with our data, but we're working on it. Please, try again later." : "Дошло је до грешке у нашим подацима, али радимо на томе. Молимо вас да покушате касније."
//            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//            self.alertDelegate?.showAlert(title: title, message: message, actions: [action])
//        }
//    }
    
    // MARK: WalkPolylines
    
    func calculateRoute(toMarker marker: GMSMarker) {
        clearPolylines()
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.currentLocation!.latitude),\(self.currentLocation!.longitude)&destination=\(marker.position.latitude),\(marker.position.longitude)&mode=walking&key=AIzaSyDrBwOZfhxn9PxoCOR18GMIaTBuDjamzRA"
        
        if let path = URL(string: url) {
            do {
                
                let data = try String(contentsOf: path, encoding: String.Encoding.utf8)
                let jData = data.data(using: String.Encoding.utf8)
                do {
                    let json = try JSONSerialization.jsonObject(with: jData!, options: []) as? [String: Any]
                    
                    let routes = json!["routes"] as! [[String: Any]]
                    for route in routes {
                        
                        let legs = route["legs"] as! [[String: Any]]
                        var totalDistance = 0
                        for leg in legs {
                            
                            let steps = leg["steps"] as! [[String: Any]]
                            for step in steps {
                                
                                let distance = step["distance"] as! [String:Any]
                                let distanceValue = distance["value"] as! Int
                                let startLocation = step["start_location"] as! [String: Any]
                                let endLocation = step["end_location"] as! [String: Any]
                                let polyPath = GMSMutablePath()
                                let startCoords = CLLocationCoordinate2DMake(startLocation["lat"] as! CLLocationDegrees, startLocation["lng"] as! CLLocationDegrees)
                                let endCoords = CLLocationCoordinate2DMake(endLocation["lat"] as! CLLocationDegrees, endLocation["lng"] as! CLLocationDegrees)
                                polyPath.add(startCoords)
                                polyPath.add(endCoords)
                                
                                let walkPolyline = GMSPolyline(path: polyPath)
                                let anotherStyle = GMSStrokeStyle.gradient(from: UIColor.yellow, to: UIColor.blue)
                                let strokeStyles = [anotherStyle, GMSStrokeStyle.solidColor(UIColor.clear)]
                                let dashLenghts: [NSNumber] = [4,2]
                                let lenghtKind = GMSLengthKind.geodesic
                                walkPolyline.spans = GMSStyleSpans(polyPath, strokeStyles, dashLenghts, lenghtKind)
                                walkPolyline.strokeWidth = 2
                                walkPolyline.map = self.mapView
                                self.walkPolyLineArray.append(walkPolyline)
                                totalDistance += distanceValue
                                
                            }
                        }
                        var newDictValue = marker.userData as! [String:Any]
                        newDictValue.updateValue("\(totalDistance) m", forKey: "distance")
                        marker.userData = newDictValue
                    }
                } catch {
                    print("Bad json")
                    let title = language == "latin" ? "WARNING!" : "УПОЗОРЕЊЕ!"
                    let message = language == "latin" ? "Something went wrong with our data, but we're working on it. Please, try again later." : "Дошло је до грешке у нашим подацима, али радимо на томе. Молимо вас да покушате касније."
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    self.alertDelegate?.showAlert(title: title, message: message, actions: [action])
                }
            } catch {
                print("Bad path")
                if self.currentReachabilityStatus == .notReachable {
                    if self.alertCounter == 0 || self.alertCounter == 5 {
                        
                        let title = language == "latin" ? "WARNING!" : "УПОЗОРЕЊЕ!"
                        let message = language == "latin" ? "You need internet connection for directions to station!" : "Потребна је интернет конекција за навођење до станице!"
                        let cancelAction = UIAlertAction(title: language == "latin" ? "Cancel" : "Откажи", style: .default, handler: nil)
                        let settingsAction = UIAlertAction(title: language == "latin" ? "Settings" : "Подешавања", style: .default) { (_) -> Void in
                            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                                return
                            }
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                })
                            }
                        }
                        self.alertDelegate?.showAlert(title: title, message: message, actions: [settingsAction, cancelAction])
                        
                    }
                    self.alertCounter += 1
                    if self.alertCounter == 5 {
                        self.alertCounter = 0
                    }
                } else {
                    let title = language == "latin" ? "WARNING!" : "УПОЗОРЕЊЕ!"
                    let message = language == "latin" ? "Something went wrong with our data, but we're working on it. Please, try again later." : "Дошло је до грешке у нашим подацима, али радимо на томе. Молимо вас да покушате касније."
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    self.alertDelegate?.showAlert(title: title, message: message, actions: [action])
                }
            }
        } else {
            print("Bad url")
            let title = language == "latin" ? "WARNING!" : "УПОЗОРЕЊЕ!"
            let message = language == "latin" ? "Something went wrong with our data, but we're working on it. Please, try again later." : "Дошло је до грешке у нашим подацима, али радимо на томе. Молимо вас да покушате касније."
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            self.alertDelegate?.showAlert(title: title, message: message, actions: [action])
        }
    }
    //MARK: Clear Polylines
    func clearPolylines() {
        for line in walkPolyLineArray {
            line.map = nil
        }
        walkPolyLineArray = []
        for line in drivePolyLineArray {
            line.map = nil
        }
        drivePolyLineArray = []
    }
    
    //MARK: - MapView Delegates
    
//    let destinationMarker = GMSMarker()
//    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
//        
//        destinationMarker.map = nil
//        destinationMarker.map = mapView
//        destinationMarker.position = coordinate
//        destinationMarker.userData = ["latitude": coordinate.latitude, "longitude": coordinate.longitude]
//        //  calculateDrivingRoute(toDestination: coordinate)
//    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        currentBearing = position.bearing
        currentAngle = position.viewingAngle
        currentZoomLevel = position.zoom
        if mapView.superview!.tag == MapViewSource.Main.rawValue {
            if position.zoom >= 15 {
                markStation(forPosition: position)
            } else {
                mapView.clear()
                notificationLabel.text = language == "latin" ? "Zoom-in to see stations" : "Зумирајте да видите станице"
                labelAnimate(string: notificationLabel.text!)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        if mapView.superview!.tag == MapViewSource.Main.rawValue {
            if position.zoom >= 15 {
                circle?.map = nil
                circle = GMSCircle(position: position.target, radius: 300)
                circle?.fillColor = UIColor(red: 0.0, green: 0.0, blue: 0.7, alpha: 0.05)
                circle?.strokeColor = UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.5)
                circle?.strokeWidth = 1
                circle?.map = mapView
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // destinationMarker.map = nil
        clearPolylines()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        activityDelegate?.isIndicatorActive(value: true)
        //mapView.selectedMarker?.map = nil // kad se ovo skine, onda cima kod prelaska sa markera na marker, a sa ovim, klik na centrirani marker, brise marker
        //mapView.selectedMarker = marker
        
            if mapView.superview!.tag == MapViewSource.Main.rawValue {
                
                DispatchQueue.global().async {
                    if self.currentLocation != nil {
                        self.calculateRoute(toMarker: marker)
                    }
                    DispatchQueue.main.async {
                        mapView.selectedMarker = marker
                        self.activityDelegate?.isIndicatorActive(value: false)
                    }
                }
            
                switch self.currentZoomLevel {
                case 15..<17:
                    marker.icon = UIImage(named: "fullRedCircle")
                case 17...mapView.maxZoom:
                    marker.icon = UIImage(named: (marker.userData as! [String: Any])["markerImage"] as! String + "Full")
                default:
                    break
                }
            } else {
                marker.icon = UIImage(named: "fullRedCircle")
            }
        
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            let camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: self.currentZoomLevel, bearing: self.currentBearing, viewingAngle: self.currentAngle)
            mapView.animate(to: camera)
            CATransaction.commit()
        
            self.currentMarkerIcon.image = marker.icon
            mapView.selectedMarker = marker
        
            self.notificationLabel.text = language == "latin" ? "Tap the USSD code to copy to clipboard" : "Кликните на USSD код, да га копирате"
            self.labelAnimate(string: self.notificationLabel.text!)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let copy = UIPasteboard.general
        copy.string = (marker.userData as! [String: Any])["code"] as? String
        notificationLabel.text = language == "latin" ? "Paste the code into phone dialer" : "Прекопирајте код у телефон (позив)"
        labelAnimate(string: notificationLabel.text!)
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        switch mapView.superview!.tag {
        case MapViewSource.Main.rawValue :
            let mainInfoWindow = mainScreenMarkerInfoWindow(marker: marker)
            crosshair.isHidden = true
            return mainInfoWindow
        case MapViewSource.Detail.rawValue:
            let detailInfoWindow = detailScreenMarkerInfoWindow(marker: marker)
            return detailInfoWindow
        default:
            print("none")
            return UIView()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        
        crosshair.isHidden = false
        if mapView.superview?.tag == 1 {
            
            switch currentZoomLevel {
            case 15..<17:
                marker.icon = UIImage(named: "redCircle")
            case 17...mapView.maxZoom:
                marker.icon = UIImage(named: (marker.userData as! [String: Any])["markerImage"] as! String)
            default:
                break
            }
            
        } else {
            marker.icon = UIImage(named: "whiteRedCircle")
        }
        
        notificationLabel.text = language == "latin" ? "Tap the station marker to see details" : "Кликните маркер да видите детаље"
        labelAnimate(string: notificationLabel.text!)
    }
    
    //MARK: - Location button delegates
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        if let myLocation = locationManager.location?.coordinate {
            let camera = GMSCameraPosition.camera(withTarget: myLocation, zoom: 15)
            mapView.camera = camera
        } else {
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: {_ in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            })
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertDelegate?.showAlert(title: "Location Services Off", message: "Enable Location Services in Settings > Privacy to enable your location", actions: [settingsAction, okAction])
        }
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined || status == .denied || status == .restricted {
            locationManager.stopUpdatingLocation()
            mapView.isMyLocationEnabled = false
        } else {
            mapView.isMyLocationEnabled = true
        }
    }
}


extension Array where Element: NSMutableAttributedString {
    func joined(separator: NSMutableAttributedString) -> NSMutableAttributedString {
        var isFirst = true
        return self.reduce(NSMutableAttributedString()) {
            (r, e) in
            if isFirst {
                isFirst = false
            } else {
                r.append(separator)
            }
            r.append(e)
            return r
        }
    }
    
    func joined(separator: String) -> NSMutableAttributedString {
        return joined(separator: NSMutableAttributedString(string: separator))
    }
}
