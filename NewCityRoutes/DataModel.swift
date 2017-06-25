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

var language = "latin"
var featureArray = [Feature]()
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
    var amenity: String
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
class Relations: NSObject, NSCoding {
    var role: String!
    var rel: Int!
    var reltags: Reltags!
    
    override var hashValue: Int {
        return rel
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Relations {
            return self.rel == other.rel
        } else {
            return false
        }
    }
    
    init(role: String, rel: Int, reltags: Reltags) {
        self.role = role
        self.rel = rel
        self.reltags = reltags
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(role, forKey: "role")
        aCoder.encode(rel, forKey: "rel")
        aCoder.encode(reltags, forKey: "reltags")
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let rolee = aDecoder.decodeObject(forKey: "role") as? String {
            self.role = rolee
        }
        if let rell = aDecoder.decodeObject(forKey: "rel") as? Int {
            self.rel = rell
        }
        if let reltagss = aDecoder.decodeObject(forKey: "reltags") as? Reltags {
            self.reltags = reltagss
        }
        
    }
}

//3
class Reltags: NSObject, NSCoding {
    var from: String!
    var fromSrLatn: String!
    var relName: String!
    var reltagRef: String!
    var route: String!
    var to: String!
    var toSrLatn: String!
    var type: String!
    var reltagLineRef: Int!
    
    override var hashValue: Int {
        return reltagLineRef
    }
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Reltags {
            return self.reltagLineRef == other.reltagLineRef
        } else {
            return false
        }
    }
    
    init(from: String, fromSrLatn: String, relName: String, reltagRef: String, route: String, to: String, toSrLatn: String, type: String, reltagLineRef: Int) {
        self.from = from
        self.fromSrLatn = fromSrLatn
        self.relName = relName
        self.reltagRef = reltagRef
        self.route = route
        self.to = to
        self.toSrLatn = toSrLatn
        self.type = type
        self.reltagLineRef = reltagLineRef
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(from, forKey: "from")
        aCoder.encode(fromSrLatn, forKey: "fromSrLatn")
        aCoder.encode(relName, forKey: "relName")
        aCoder.encode(reltagRef, forKey: "reltagRef")
        aCoder.encode(route, forKey: "route")
        aCoder.encode(to, forKey: "to")
        aCoder.encode(toSrLatn, forKey: "toSrLatn")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(reltagLineRef, forKey: "reltagLineRef")
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let fromm = aDecoder.decodeObject(forKey: "from") as? String {
            self.from = fromm
        }
        if let fromSrLatnn = aDecoder.decodeObject(forKey: "fromSrLatn") as? String {
            self.fromSrLatn = fromSrLatnn
        }
        if let relNamee = aDecoder.decodeObject(forKey: "relName") as? String {
            self.relName = relNamee
        }
        if let reltagReff = aDecoder.decodeObject(forKey: "reltagRef") as? String {
            self.reltagRef = reltagReff
        }
        if let routee = aDecoder.decodeObject(forKey: "route") as? String {
            self.route = routee
        }
        if let too = aDecoder.decodeObject(forKey: "to") as? String {
            self.to = too
        }
        if let toSrLatnn = aDecoder.decodeObject(forKey: "toSrLatn") as? String {
            self.toSrLatn = toSrLatnn
        }
        if let typee = aDecoder.decodeObject(forKey: "type") as? String {
            self.type = typee
        }
        if let reltagLineReff = aDecoder.decodeObject(forKey: "reltagLineRef") as? Int {
            self.reltagLineRef = reltagLineReff
        }
        
    }
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

class Routes: NSObject, NSCoding {
    var ref: String = ""
    var route: String = ""
    var routes: [Relations] = []
    var lineRef: Int?
    
    override var hashValue: Int {
        return lineRef!
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? Routes {
            if let initial = self.lineRef {
                return initial == other.lineRef
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    init(ref: String, route: String, routes: [Relations], lineRef: Int) {
        self.ref = ref
        self.route = route
        self.routes = routes
        self.lineRef = lineRef
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(ref, forKey: "ref")
        aCoder.encode(route, forKey: "route")
        aCoder.encode(routes, forKey: "routes")
        aCoder.encode(lineRef, forKey: "lineRef")
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let reff = aDecoder.decodeObject(forKey: "ref") as? String {
            self.ref = reff
        }
        if let routee = aDecoder.decodeObject(forKey: "route") as? String {
            self.route = routee
        }
        if let routess = aDecoder.decodeObject(forKey: "routes") as? [Relations] {
            self.routes = routess
        }
        if let lineReff = aDecoder.decodeObject(forKey: "lineRef") as? Int {
            self.lineRef = lineReff
        }
    }
}

