//
//  Appearance.swift
//  NewCityRoutes
//
//  Created by Marko Tribl on 6/3/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

struct Appearance {
    static func setGlobalAppearance() {
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().barTintColor = .clear
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Copperplate-Light", size: 15)!]
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        
    }
}
