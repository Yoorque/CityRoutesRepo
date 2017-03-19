//
//  CalculateNearestStation.swift
//  NewCityRoutes
//
//  Created by Marko Tribl on 3/9/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import Foundation
import CoreLocation

struct CalculateNearestStation {
    
    private var radius = 300.0
    var featuresForNearestStation = [Feature]()
    
    mutating func calculateNearestStation(from userLocation: CLLocationCoordinate2D?) -> [CLLocation] {
        var locations = [CLLocation]()
        featuresForNearestStation.removeAll()
        
        if let latitude = userLocation?.latitude, let longitude = userLocation?.longitude {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            
            for feature in featureArray {
                if feature.property.highway == "bus_stop" || feature.property.highway == "tram_stop" {
                    for coord in feature.geometry.coordinates {
                        let coords: CLLocation = CLLocation(latitude: coord.lat, longitude: coord.lon)
                        // print("koordinate: \(coords)")
                        let distance: CLLocationDistance = coords.distance(from: location)
                        if distance <= radius {
                            locations.append(coords)
                            featuresForNearestStation.append(feature)
                        }
                    }
                }
            }
        }
        // print("Feature for nearest station: \(featuresForNearestStation.count)")
        return locations
    }
}

