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
    
    let locationManager = CLLocationManager()
    var mapView: GMSMapView!
    var detailMarker: GMSMarker!
    var linije = ""
    var infoWindow = CustomInfoWindow()
    var selectedFeature = [Feature]()
    var selectedRelation = [Relations]()
    var i = 0
    
    func createMap(view: UIView) {
        let location = CLLocationCoordinate2DMake(44.787197, 20.457273)
        let camera = GMSCameraPosition.camera(withTarget: location, zoom: 10)
        
        mapView = GMSMapView.map(withFrame: CGRect(x:0, y: 0, width: view.bounds.width, height: view.bounds.height) ,camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        view.addSubview(mapView)
    }
    
    //Izvlaci i filtrira odabranu vrstu prevoza i poziva se iz DetailViewController-a
    func drawTransportLines(route: Relations) {
        mapView.clear()
        
        for feature in featureArray {
            for relation in feature.property.relations {
                // print(relation.reltags.route, route.reltags.route)
                if relation.reltags.route == route.reltags.route {
                    if relation.rel == route.rel {
                        if feature.property.highway == "bus_stop" || feature.property.railway == "tram_stop" {
                            for coord in feature.geometry.coordinates {
                                
                                iscrtavanjeCoordinata(coord: coord, feature: feature, relation: route)
                                
                            }
                        }
                    }
                }
                
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
            linije = ""
        }
    }
    // Iscrtava rutu i markere u zavisnosti od odabrane u drawTransportLines() odakle se i poziva
    
    func iscrtavanjeCoordinata(coord: Coordinates, feature: Feature, relation: Relations) {
        selectedFeature.append(feature)
        selectedRelation.append(relation)
        let coords = CLLocationCoordinate2DMake(coord.lat, coord.lon)
        let camera = GMSCameraPosition(target: coords, zoom: 13, bearing: 0, viewingAngle: 0)
        mapView.camera = camera
        detailMarker = GMSMarker(position:coords)
        detailMarker.accessibilityLabel = "\(i)"
        i += 1
        detailMarker.icon = UIImage(named: "redCircle")
        detailMarker.map = mapView
        detailMarker.title = feature.property.name
        
        for rela in feature.property.relations {
            if rela.reltags.ref != relation.reltags.ref {
                linije = linije + " " + rela.reltags.ref
            }
        }
        
        detailMarker.snippet = linije
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        infoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?.first as! CustomInfoWindow
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
        
        infoWindow.stationName.text = marker.title
        infoWindow.otherLines.text = marker.snippet
        infoWindow.selectedLine.text = selectedRelation[index].reltags.ref
        infoWindow.imageView.image = UIImage(named: selectedRelation[index].reltags.route)
        
        return infoWindow
    }
}

