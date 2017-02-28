//
//  CustomInfoWindow.swift
//  cityRoutes
//
//  Created by Dusan Juranovic on 2/16/17.
//  Copyright © 2017 Marko Tribl. All rights reserved.
//

import UIKit
@IBDesignable
class CustomInfoWindow: UIView {
    @IBInspectable
    @IBOutlet var imageView: UIImageView!
    @IBInspectable
    @IBOutlet var selectedLine: UILabel!
    @IBOutlet var otherLines: UILabel!
    @IBOutlet var stationName: UILabel!
    @IBOutlet var code: UILabel!
    
    @IBOutlet var coveredImage: UIImageView!
    
    @IBOutlet var wheelchairImage: UIImageView!
}
