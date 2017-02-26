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
    
    
    func createMap(view: UIView) {
        let location = CLLocationCoordinate2DMake(44.787197, 20.457273)
        let camera = GMSCameraPosition.camera(withTarget: location, zoom: 10)
        
        mapView = GMSMapView.map(withFrame: CGRect(x:0, y: 0, width: view.bounds.width, height: view.bounds.height) ,camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        view.addSubview(mapView)
    }
    
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
    
    var selectedFeatureVar: Feature?
    var selectedRelaitionVar: Relations?
    func iscrtavanjeCoordinata(coord: Coordinates, feature: Feature, relation: Relations) {
        selectedFeatureVar = feature
        selectedRelaitionVar = relation
        let coords = CLLocationCoordinate2DMake(coord.lat, coord.lon)
        let camera = GMSCameraPosition(target: coords, zoom: 13, bearing: 0, viewingAngle: 0)
        mapView.camera = camera
        detailMarker = GMSMarker(position:coords)
        detailMarker.icon = UIImage(named: "redCircle")
        detailMarker.map = mapView
        detailMarker.title = feature.property.name
        detailMarker.accessibilityLanguage = relation.reltags.ref
        
        
        for rela in feature.property.relations {
            if rela.reltags.ref != relation.reltags.ref {
                linije = linije + " " + rela.reltags.ref
            }
        }
        
        detailMarker.snippet = linije
        
        if feature.property.phone != "" {
            detailMarker.accessibilityLabel = feature.property.phone
        } else if feature.property.codeRef != "" {
            detailMarker.accessibilityLabel = "*011*\(feature.property.codeRef)#"
        } else {
            detailMarker.accessibilityLabel = ""
        }
        
        if feature.property.covered != "" {
            detailMarker.accessibilityValue = feature.property.covered
        } else if feature.property.shelter != "" {
            detailMarker.accessibilityValue = feature.property.shelter
        }
        
        if feature.property.wheelchair != "" {
            detailMarker.accessibilityHint = feature.property.wheelchair
            print(relation.reltags.route)
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        infoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?.first as! CustomInfoWindow
        
        infoWindow.layer.borderWidth = 2
        infoWindow.layer.cornerRadius = 13
        infoWindow.layer.borderColor = UIColor.red.cgColor
        
        infoWindow.stationName.text = selectedFeatureVar!.property.name
        infoWindow.code.text = marker.accessibilityLabel
        infoWindow.otherLines.text = marker.snippet
        infoWindow.selectedLine.text = selectedRelaitionVar!.reltags.ref
        infoWindow.imageView.image = UIImage(named: selectedRelaitionVar!.reltags.route)        
        
        func customInfoWindowData() {
            
        }
        
        return infoWindow
    }
}

