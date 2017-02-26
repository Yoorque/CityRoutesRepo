//
//  DataModel.swift
//  cityRoutes
//
//  Created by Dusan Juranovic on 2/5/17.
//  Copyright © 2017 Marko Tribl. All rights reserved.
//
func ==(left: Relations, right: Relations) -> Bool {
    return left.rel == right.rel
}

func ==(left: Property, right: Property) -> Bool {
    return left.relations.count == right.relations.count
}

func ==(left: Routes, right: Routes) -> Bool {
    return left.lineRef == right.lineRef
}

import Foundation

//Deklaracije




var featureArray = [Feature]()


var recentArray = [Recent]()

var odabraniSmer: Int?

struct Feature {
    var id: String
    var property: Property 
    var geometry: Geometry
    
}
//1
struct Property: Hashable {
    var id: String
    var highway: String
    var railway: String
    var name: String
    var nameSrLatn: String
    var relations: [Relations]
    var covered: String
    var phone: String
    var codeRef: String
    var shelter: String
    var wheelchair:String
    var hashValue: Int {
        return relations.count
    }
}
//2
struct Relations: Hashable {
    var role: String
    var rel: Int
    var reltags: Reltags
    var hashValue: Int {
        return rel
    }
}
//3
struct Reltags {
    var from: String
    var relName: String
    var ref: String
    var route: String
    var to: String
    var type: String
    var lineRef: Int
}
//1
struct Geometry {
    var type: String
    var coordinates: [Coordinates]
}
//2
struct Coordinates {
    var lat: Double
    var lon: Double
}

struct Routes: Hashable {
    var ref: String
    var route: String
    var routes: [Relations]
    var lineRef: Int
    var hashValue: Int {
        return lineRef
    }
}


//Favorites

struct Favorite {
    
}

//Recent

struct Recent {
    
}
