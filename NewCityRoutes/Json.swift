//
//  Json.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/26/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import Foundation

struct Json {
    
    private var property: Property?
    private var geom: Geometry?
    private var relationArray = [Relations]()
    private var coordArray = [Coordinates]()
    
    static var selectedTransportArray = [Relations]()
    static var routesArray = [Routes]()
    static var routesSet: Set<Routes> = []
    
    mutating func readJson() {
        
        if let path = Bundle.main.path(forResource: "Lines", ofType: "geojson") {
            do {
                let file = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                let jData = file.data(using: String.Encoding.utf8)
                do {
                    let json = try JSONSerialization.jsonObject(with: jData!, options: []) as![String: Any]
                    let features = json["features"] as! [[String:Any]]
                    for feature in features {
                        let featureId = feature["id"] as! String
                        let properties = feature["properties"] as! [String:Any]
                        
                        let propertyId = properties["@id"] as! String
                        let highway = properties["highway"] as? String ?? ""
                        let amenity = properties["amenity"] as? String ?? ""
                        let railway = properties["railway"] as? String ?? ""
                        let name = properties["name"] as? String ?? ""
                        let nameSrLatn = properties["name:sr-Latn"] as? String ?? ""
                        let phone = properties["phone"] as? String ?? ""
                        let covered = properties["covered"] as? String ?? ""
                        let codeRef = properties["ref"] as? String ?? ""
                        let shelter = properties["shelter"] as? String ?? ""
                        let wheelchair = properties["wheelchair"] as? String ?? ""
                        let relations = properties["@relations"] as? [[String:Any]] ?? [[:]]
                        
                        for relation in relations {
                            let role = relation["role"] as? String ?? ""
                            let rel = relation["rel"] as? Int ?? 0
                            let reltags = relation["reltags"] as? [String: Any] ?? [:]
                            
                            let from = reltags["from"] as? String ?? ""
                            let fromSrLatn = reltags["from:sr-Latn"] as? String ?? ""
                            let relName = reltags["name"] as? String ?? ""
                            let ref = reltags["ref"] as? String ?? ""
                            let route = reltags["route"] as? String ?? ""
                            let to = reltags["to"] as? String ?? ""
                            let toSrLatn = reltags["to:sr-Latn"] as? String ?? ""
                            let type = reltags["type"] as? String ?? ""
                            let lineRef = reltags["lineRef"] as? String ?? ""
                            if lineRef != "" {
                                let lineNumberRef = Int(lineRef)
                                let relData = Relations(role: role, rel: rel, reltags: Reltags(from: from, fromSrLatn: fromSrLatn, relName: relName, reltagRef: ref, route: route, to: to, toSrLatn: toSrLatn ,type: type, reltagLineRef: lineNumberRef!))
                                relationArray.append(relData)
                            }
                            let geometry = feature["geometry"] as? [String:Any] ?? [:]
                            let geoType = geometry["type"] as! String
                            
                            
                            if let coordinates = geometry["coordinates"] as? [[Double]] {
                                
                                for coordinate in coordinates {
                                    let lat = coordinate[1]
                                    let lon = coordinate[0]
                                    coordArray.append(Coordinates(lat: lat, lon: lon))
                                }
                                
                            } else if let coordinates = geometry["coordinates"] as? [Double] {
                                let lat = coordinates[1]
                                let lon = coordinates[0]
                                coordArray.append(Coordinates(lat: lat, lon: lon))
                            }
                            
                            geom = Geometry(type: geoType, coordinates: coordArray)
                            coordArray = []
                        }
                        property = Property(id: propertyId, highway: highway, railway: railway, amenity: amenity, name: name, nameSrLatn: nameSrLatn, relations: relationArray, covered: covered, phone: phone, codeRef: codeRef, shelter: shelter, wheelchair: wheelchair)
                        let feature = Feature(id: featureId, property: property!, geometry: geom!)
                        
                        featureArray.append(feature)
                        relationArray = []
                    }
                } catch {
                    print("Bad json")
                }
            }catch {
                print("No go")
            }
        } else {
            print("No File")
        }
    }
    
    static func sortedTransport(route: String) -> [Routes] {
        var selectedTransportSet = Set<Relations>()
        routesArray = []
        selectedTransportArray = []
        routesSet = []
        selectedTransportSet = []
        
        for feature in featureArray {
            for relation in feature.property.relations {
                if relation.reltags.route == route {
                    selectedTransportSet.insert(relation)
                }
            }
        }
        
        for s in selectedTransportSet {
            if s.reltags.reltagRef != "" {
                
                selectedTransportArray.append(s)
            }
        }
        
        for i in 0..<selectedTransportArray.count {
            for j in 0..<selectedTransportArray.count {
                if selectedTransportArray[i].rel != selectedTransportArray[j].rel {
                    if selectedTransportArray[i].reltags.reltagLineRef == selectedTransportArray[j].reltags.reltagLineRef {
                        
                        let routes = Routes(ref: selectedTransportArray[i].reltags.reltagRef, route: selectedTransportArray[i].reltags.route, routes: [selectedTransportArray[i], selectedTransportArray[j]], lineRef:selectedTransportArray[i].reltags.reltagLineRef)
                        routesSet.insert(routes)
                    }
                } else {
                    if selectedTransportArray[i].reltags.reltagLineRef == selectedTransportArray[j].reltags.reltagLineRef {
                        if selectedTransportArray[i].reltags.from == selectedTransportArray[j].reltags.to {
                            let routes = Routes(ref: selectedTransportArray[i].reltags.reltagRef, route: selectedTransportArray[i].reltags.route, routes: [selectedTransportArray[i], selectedTransportArray[j]], lineRef:selectedTransportArray[i].reltags.reltagLineRef)
                            routesSet.insert(routes)
                        }
                    }
                }
            }
        }
        
        return routesSet.sorted(by: {$0.lineRef < $1.lineRef})
    }
}
