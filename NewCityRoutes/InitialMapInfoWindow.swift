//
//  MainInfoWindow.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 3/17/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class InitialMapInfoWindow: UIView {

   
    @IBOutlet var stationUnderView: UIView! {
        didSet {
            stationUnderView.layer.borderColor = UIColor.red.cgColor
            stationUnderView.layer.borderWidth = 2
            stationUnderView.layer.cornerRadius = 7
        }
    }
    @IBOutlet var underView: UIView! {
        didSet {
            underView.layer.borderColor = UIColor.red.cgColor
            underView.layer.borderWidth = 2
            underView.layer.cornerRadius = 7
        }
    }
    @IBOutlet var stationName: UILabel!
    @IBOutlet var otherLinesLabel: UILabel!
    @IBOutlet var code: UILabel! 
}
