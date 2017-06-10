//
//  CreateMapView.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/25/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import GoogleMaps

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
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
    
    var currentMarkerIcon = UIImage()
    var crosshair = UIImageView()
    var currentZoomLevel: Float!
    var mapView: GMSMapView!
    var detailMarker: GMSMarker!
    var linije = NSAttributedString()
    var viewController = InitialViewController()
    var selectedFeature = [Feature]()
    var selectedRelation = [Relations]()
    var i = 0
    var notificationLabel = UILabel()
    
    let locationManager = CLLocationManager()
    var nearestLocation = CalculateNearestStation()
    let simPosition = CLLocationCoordinate2D(latitude: 44.818611, longitude: 20.468056)
    var currentLocation: CLLocationCoordinate2D {
        return locationManager.location?.coordinate ?? simPosition
    }
    
    //MARK: MapView Helper Methods
    
    func createMap(view: UIView) {
        // Testing on a device
        let camera = GMSCameraPosition.camera(withTarget: currentLocation, zoom: 15)
        
        mapView = GMSMapView.map(withFrame: CGRect(x:0, y: 0, width: view.bounds.width, height: view.bounds.height) ,camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        mapView.delegate = self
        view.addSubview(mapView)
        
        createNotificationLabel(view: view)
        
        notificationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        notificationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        notificationLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        notificationLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
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
        //        notificationLabel.frame = CGRect(x: view.bounds.size.width / 2 - 100, y: view.bounds.maxY - 30, width: 200, height: 20)
        notificationLabel.textAlignment = .center
        notificationLabel.textColor = .red
        notificationLabel.adjustsFontSizeToFitWidth = true
        
        notificationLabel.autoresizingMask = .flexibleWidth
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.font = UIFont.boldSystemFont(ofSize: 12)
        view.addSubview(notificationLabel)
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
        
        linije = NSAttributedString()
        
        selectedFeature.append(feature)
        selectedRelation.append(relation)
        
        let coords = CLLocationCoordinate2DMake(coord.lat, coord.lon)
        
        let camera = GMSCameraPosition(target: coords, zoom: 13, bearing: 0, viewingAngle: 0)
        mapView.camera = camera
        
        detailMarker = GMSMarker(position:coords)
        detailMarker.accessibilityLabel = "\(i)"
        i += 1
        detailMarker.icon = UIImage(named: "redCircle")
        detailMarker.appearAnimation = GMSMarkerAnimation.pop
        detailMarker.map = mapView
        
        for rela in feature.property.relations {
            if rela.reltags.reltagRef != relation.reltags.reltagRef {
                
                linije = linije + NSAttributedString(string: " ") + NSAttributedString(string: rela.reltags.reltagRef, attributes: [NSForegroundColorAttributeName: UIColor.color(forTransport: rela.reltags.route)])
            }
            
            detailMarker.userData = linije
        }
    }
    
    // Calculate nearest station from user location
    
    func markStation(forPosition position: GMSCameraPosition) {
        mapView.clear()
        nearestLocation.calculateNearestStation(from: mapView.camera.target)
        
        var transportImageNames = Set<String>()
        var finalIconImageName = ""
        linije = NSAttributedString()
        i = 0
        selectedFeature.removeAll()
        
        selectedFeature = nearestLocation.featuresForNearestStation
        
        for feature in selectedFeature {
            for relation in feature.property.relations {
                linije = linije + NSAttributedString(string: " ") + NSAttributedString(string: relation.reltags.reltagRef, attributes: [NSForegroundColorAttributeName: UIColor.color(forTransport: relation.reltags.route)])
                
                transportImageNames.insert(relation.reltags.route)
            }
            
            let lat = feature.geometry.coordinates[0].lat
            let lon = feature.geometry.coordinates[0].lon
            let pos = CLLocationCoordinate2DMake(lat, lon)
            detailMarker = GMSMarker(position: pos)
            
            detailMarker.appearAnimation = GMSMarkerAnimation.pop
            detailMarker.map = mapView
            detailMarker.accessibilityLabel = "\(i)"
            i += 1
            switch position.zoom {
            case 15..<18:
                detailMarker.icon = UIImage(named: "redCircle")
            case 18...mapView.maxZoom:
                for image in transportImageNames {
                    finalIconImageName = finalIconImageName + image
                }
                
                detailMarker.icon = UIImage(named: finalIconImageName)
            default:
                break
            }
            
            detailMarker.userData = linije
            detailMarker.snippet = feature.property.phone != "" ? feature.property.phone : "*011*\(feature.property.codeRef)#"
            linije = NSAttributedString()
            transportImageNames = []
            finalIconImageName = ""
        }
    }
    
    func mainScreenMarkerInfoWindow(marker: GMSMarker) -> UIView{
        let infoWindow = Bundle.main.loadNibNamed("InitialMapInfoWindow", owner: self, options: nil)?.first as! InitialMapInfoWindow
        let index = Int(marker.accessibilityLabel!)!
        
        infoWindow.otherLinesLabel.attributedText = marker.userData as? NSAttributedString
        
        infoWindow.code.text = marker.snippet
        infoWindow.stationName.text = language == "latin" ? selectedFeature[index].property.nameSrLatn : selectedFeature[index].property.name
        
        infoWindow.otherLinesLabel.sizeToFit()
        infoWindow.stationName.sizeToFit()
        
        infoWindow.frame.size = CGSize(width: 218, height: 5 + infoWindow.stationName.frame.height + infoWindow.stationUnderView.frame.height + 5 + infoWindow.otherLinesLabel.frame.height + (infoWindow.underView.frame.height - 25))
        
        return infoWindow
    }
    
    func detailScreenMarkerInfoWindow(marker: GMSMarker) -> UIView {
        let infoWindow = Bundle.main.loadNibNamed("DetailMapInfoWindow", owner: self, options: nil)?.first as! DetailMapInfoWindow
        let index = Int(marker.accessibilityLabel!)!
        
        infoWindow.layer.borderWidth = 2
        infoWindow.layer.cornerRadius = 13
        infoWindow.layer.borderColor = UIColor.red.cgColor
        
        if language == "latin" {
            infoWindow.codeLanguageLabel.text = "Code"
            infoWindow.coveredLanguageLabel.text = "Covered"
            infoWindow.wheelchairLanguageLabel.text = "Wheelchair"
            infoWindow.otherLinesLanguageLabel.text = "Lines"
        } else {
            infoWindow.codeLanguageLabel.text = "Код"
            infoWindow.coveredLanguageLabel.text = "Покривена"
            infoWindow.wheelchairLanguageLabel.text = "Колица"
            infoWindow.otherLinesLanguageLabel.text = "Линије"
        }
        
        if selectedFeature[index].property.covered != "" {
            infoWindow.coveredImage.image = UIImage(named: selectedFeature[index].property.covered)
        } else if selectedFeature[index].property.shelter != ""{
            infoWindow.coveredImage.image = UIImage(named: selectedFeature[index].property.shelter)
        } else {
            infoWindow.coveredImage.image = UIImage(named: "no")
        }
        
        if selectedFeature[index].property.phone != "" {
            infoWindow.code.text = selectedFeature[index].property.phone
        } else if selectedFeature[index].property.codeRef != ""{
            infoWindow.code.text = "*011*\(selectedFeature[index].property.codeRef)#"
        } else {
            infoWindow.code.text = "no code"
        }
        
        infoWindow.wheelchairImage.image = selectedFeature[index].property.wheelchair != "" ? UIImage(named: selectedFeature[index].property.wheelchair) : UIImage(named: "no")
        
        infoWindow.stationName.text = language == "latin" ? selectedFeature[index].property.nameSrLatn : selectedFeature[index].property.name
        
        infoWindow.otherLines.attributedText = marker.userData as? NSAttributedString
        infoWindow.selectedLine.attributedText = NSAttributedString(string: selectedRelation[index].reltags.reltagRef, attributes: [NSForegroundColorAttributeName: UIColor.color(forTransport: selectedRelation[index].reltags.route)])
        infoWindow.imageView.image = UIImage(named: selectedRelation[index].reltags.route)
        
        return infoWindow
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
    
    //MARK: MapView Delegates
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        currentZoomLevel = position.zoom
        if mapView.superview!.tag == MapViewSource.Main.rawValue {
            if position.zoom >= 15 {
                notificationLabel.text = language == "latin" ? "Tap the station marker to see details" : "Кликните маркер да видите детаље"
                labelAnimate(string: notificationLabel.text!)
                markStation(forPosition: position)
            } else {
                mapView.clear()
                notificationLabel.text = language == "latin" ? "Zoom-in to see stations" : "Зумирајте да видите станице"
                labelAnimate(string: notificationLabel.text!)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        currentMarkerIcon = marker.icon!
        
        if mapView.superview!.tag == MapViewSource.Detail.rawValue {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            let camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: currentZoomLevel)
            mapView.animate(to: camera)
            CATransaction.commit()
        }
        
        mapView.selectedMarker = marker
        mapView.selectedMarker?.icon = UIImage(named: "fullRedCircle")
        
        notificationLabel.text = language == "latin" ? "Tap the USSD code to copy to clipboard" : "Кликните на USSD код, да га копирате"
        labelAnimate(string: notificationLabel.text!)
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let index = Int(marker.accessibilityLabel!)
        let copy = UIPasteboard.general
        
        copy.string = mapView.superview?.tag == 1 ? marker.snippet : selectedFeature[index!].property.phone != "" ? selectedFeature[index!].property.phone : "*011*\(selectedFeature[index!].property.codeRef)#"
        
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
        marker.icon = currentMarkerIcon
        
        notificationLabel.text = language == "latin" ? "Tap the station marker to see details" : "Кликните маркер да видите детаље"
        labelAnimate(string: notificationLabel.text!)
    }
    
    //MARK: Location button delegates
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        if let myLocation = mapView.myLocation?.coordinate {
            let camera = GMSCameraPosition.camera(withTarget: myLocation, zoom: 15)
            mapView.camera = camera
        }
        return true
    }
}

