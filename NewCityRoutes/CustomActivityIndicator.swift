//
//  CustomActivityIndicator.swift
//  NewCityRoutes
//
//  Created by Marko Tribl on 4/16/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class CustomActivityIndicator: UIView {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    func actIndicator(isShown: Bool) {
        if isShown {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            self.removeFromSuperview()
        }
    }
}
