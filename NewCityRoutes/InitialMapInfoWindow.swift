//
//  MainInfoWindow.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 3/17/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class InitialMapInfoWindow: UIView {
    
    @IBOutlet var distance: UILabel!
    @IBOutlet var stationName: UILabel!
    @IBOutlet var otherLinesLabel: UILabel!
    @IBOutlet var code: UILabel!
    
    @IBOutlet var stationUnderView: UIView! {
        didSet {
            stationUnderView.layer.borderColor = UIColor.red.cgColor
            stationUnderView.layer.borderWidth = 1.5
            stationUnderView.layer.cornerRadius = 7
        }
    }
    
    @IBOutlet var underView: UIView! {
        didSet {
            underView.layer.borderColor = UIColor.red.cgColor
            underView.layer.borderWidth = 1.5
            underView.layer.cornerRadius = 7
        }
    }
}
