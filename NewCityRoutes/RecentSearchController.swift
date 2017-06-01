//
//  RecentSearchController.swift
//  NewCityRoutes
//
//  Created by Marko Tribl on 5/31/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import Foundation

class RecentSearchController {
    let defaults = UserDefaults.standard
    var savedRoutes: [Routes] {
        get {
            if let data = defaults.value(forKey: "savedSearches") as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [Routes] ?? []
            }
            return []
        }
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            defaults.set(data, forKey: "savedSearches")
        }
    }
}
