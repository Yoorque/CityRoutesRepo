//
//  CreateMapView.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/25/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import GoogleMaps

class CreateMapView: UIView, GMSMapViewDelegate, CLLocationManagerDelegate {
    enum MapViewSource: Int {
        case Main = 1
        case Detail = 2
    }
    var mapView: GMSMapView!
    var detailMarker: GMSMarker!
    var linije = ""
    var viewController = ViewController()
    var selectedFeature = [Feature]()
    var selectedRelation = [Relations]()
    var i = 0
    var zoomLevelLabel = UILabel()
    
    let locationManager = CLLocationManager()
    var nearestLocation = CalculateNearestStation()
    
    var currentLocation: CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }
    
    func createMap(view: UIView) {

        let camera = GMSCameraPosition.camera(withTarget: currentLocation!, zoom: 13)
        
        mapView = GMSMapView.map(withFrame: CGRect(x:0, y: 0, width: view.bounds.width, height: view.bounds.height) ,camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        mapView.delegate = self
        view.addSubview(mapView)
        createZoomLabel(view: view)
    }
    
    func createZoomLabel(view: UIView) {
        zoomLevelLabel.frame = CGRect(x: view.frame.size.width / 2 - 100, y: view.frame.maxY - 30, width: 200, height: 20)
        zoomLevelLabel.textAlignment = .center
        zoomLevelLabel.textColor = .red
        zoomLevelLabel.adjustsFontSizeToFitWidth = true
        
        zoomLevelLabel.autoresizingMask = .flexibleWidth
        view.addSubview(zoomLevelLabel)
    }

    
    //Izvlaci i filtrira odabranu vrstu prevoza i poziva se iz DetailViewController-a
    func drawLineMarkers(route: Relations) {
        mapView.clear()
        
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
        linije = ""
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
             if rela.reltags.ref != relation.reltags.ref {

                linije = linije + " " + rela.reltags.ref
                
              }
        }
        
        detailMarker.snippet = linije
        
    }
    
    // MARK: Calculate nearest station from user location
    
    func markStation() {
        mapView.clear()
        nearestLocation.calculateNearestStation(from: mapView.camera.target)
        
        linije = ""
        selectedFeature.removeAll()
        
        selectedFeature = nearestLocation.featuresForNearestStation
        
        for feature in selectedFeature {
            for relation in feature.property.relations {
                linije = linije + " " + relation.reltags.ref
            }
            
            let lat = feature.geometry.coordinates[0].lat
            let lon = feature.geometry.coordinates[0].lon
            let position = CLLocationCoordinate2DMake(lat, lon)
            
            detailMarker = GMSMarker(position: position)
            detailMarker.icon = UIImage(named: "redCircle")
            detailMarker.appearAnimation = GMSMarkerAnimation.pop
            detailMarker.map = mapView
            
            detailMarker.title = linije
            detailMarker.snippet = feature.property.phone != "" ? feature.property.phone : "*011*\(feature.property.codeRef)#"
            linije = ""
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if mapView.superview!.tag == MapViewSource.Main.rawValue {
            if position.zoom >= 15 {
                zoomLevelLabel.text = "Tap the marker Info Window to copy the USSD code"
                markStation()
            } else {
                mapView.clear()
                zoomLevelLabel.text = "Zoom-in to see stations"
            }
        }
    }
    
    func mainScreenMarkerInfoWindow(marker: GMSMarker) -> UIView{
        let infoWindow = Bundle.main.loadNibNamed("MainInfoWindow", owner: self, options: nil)?.first as! MainInfoWindow
        
        infoWindow.layer.borderWidth = 2
        infoWindow.layer.cornerRadius = 13
        infoWindow.layer.borderColor = UIColor.red.cgColor
        infoWindow.otherLinesLabel.text = marker.title
        infoWindow.code.text = marker.snippet
        
        return infoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.selectedMarker = marker
        
        return true
    }
    
    func detailScreenMarkerInfoWindow(marker: GMSMarker) -> UIView {
        let infoWindow = Bundle.main.loadNibNamed("DetailInfoWindow", owner: self, options: nil)?.first as! DetailInfoWindow
        
        let index = Int(marker.accessibilityLabel!)!
        
        infoWindow.layer.borderWidth = 2
        infoWindow.layer.cornerRadius = 13
        infoWindow.layer.borderColor = UIColor.red.cgColor
        
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
        
        if selectedFeature[index].property.wheelchair != "" {
            infoWindow.wheelchairImage.image = UIImage(named: selectedFeature[index].property.wheelchair)
        } else {
            infoWindow.wheelchairImage.image = UIImage(named: "no")
        }
        if language == "latin" {
        infoWindow.stationName.text = selectedFeature[index].property.nameSrLatn
        } else {
            infoWindow.stationName.text = selectedFeature[index].property.name
        }
        infoWindow.otherLines.text = marker.snippet
        infoWindow.selectedLine.text = selectedRelation[index].reltags.ref
        infoWindow.imageView.image = UIImage(named: selectedRelation[index].reltags.route)
        
        return infoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let copy = UIPasteboard.general
        copy.string = marker.snippet
        zoomLevelLabel.text = "Paste you code into phone dialer"
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        switch mapView.superview!.tag {
        case MapViewSource.Main.rawValue :
            let mainInfoWindow = mainScreenMarkerInfoWindow(marker: marker)
            return mainInfoWindow
        case MapViewSource.Detail.rawValue:
            let detailInfoWindow = detailScreenMarkerInfoWindow(marker: marker)
            return detailInfoWindow
        default:
            print("none")
            return UIView()
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        if let myLocation = mapView.myLocation?.coordinate {
            let camera = GMSCameraPosition.camera(withTarget: myLocation, zoom: 15)
            mapView.camera = camera
        }
        return true
    }
}

