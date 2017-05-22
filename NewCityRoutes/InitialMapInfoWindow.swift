//
//  MainInfoWindow.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 3/17/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class InitialMapInfoWindow: UIView {
    
    @IBOutlet var stationName: UILabel!
    @IBOutlet var otherLinesLabel: UILabel!
    @IBOutlet var code: UILabel!
    
    @IBOutlet var stationUnderView: UIView! {
        didSet {
            
            stationUnderView.layer.borderColor = UIColor.red.cgColor
            stationUnderView.layer.borderWidth = 1.5
            stationUnderView.layer.cornerRadius = 7
            
            stationUnderView.translatesAutoresizingMaskIntoConstraints = false
            stationUnderView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            stationUnderView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
            stationUnderView.widthAnchor.constraint(equalTo: self.widthAnchor)
            stationUnderView.heightAnchor.constraint(equalToConstant: 18).isActive = true
            
            stationName.font = UIFont.boldSystemFont(ofSize: 11)
            stationName.translatesAutoresizingMaskIntoConstraints = false
            stationName.centerXAnchor.constraint(equalTo: stationUnderView.centerXAnchor).isActive = true
            stationName.centerYAnchor.constraint(equalTo: stationUnderView.centerYAnchor).isActive = true
            stationName.widthAnchor.constraint(equalTo: stationUnderView.widthAnchor, constant: -10).isActive = true
            stationName.heightAnchor.constraint(equalTo: stationUnderView.heightAnchor).isActive = true
        }
    }
    
    @IBOutlet var underView: UIView! {
        didSet {
            underView.layer.borderColor = UIColor.red.cgColor
            underView.layer.borderWidth = 1.5
            underView.layer.cornerRadius = 7
            underView.translatesAutoresizingMaskIntoConstraints = false
            underView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            underView.topAnchor.constraint(equalTo: stationUnderView.bottomAnchor, constant: 5).isActive = true
            underView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            underView.heightAnchor.constraint(equalTo: otherLinesLabel.heightAnchor, constant: 5).isActive = true
            underView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
            
            otherLinesLabel.font = UIFont.boldSystemFont(ofSize: 11)
            otherLinesLabel.translatesAutoresizingMaskIntoConstraints = false
            otherLinesLabel.textAlignment = NSTextAlignment.left
            otherLinesLabel.leftAnchor.constraint(equalTo: underView.leftAnchor, constant: 5).isActive = true
            otherLinesLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
            otherLinesLabel.centerYAnchor.constraint(equalTo: underView.centerYAnchor).isActive = true
            
            code.translatesAutoresizingMaskIntoConstraints = false
            code.font = UIFont.boldSystemFont(ofSize: 11)
            code.leftAnchor.constraint(equalTo: otherLinesLabel.rightAnchor, constant: 5).isActive = true
            code.rightAnchor.constraint(equalTo: underView.rightAnchor, constant: 5).isActive = true
            code.heightAnchor.constraint(equalToConstant: 20).isActive = true
            code.centerYAnchor.constraint(equalTo: underView.centerYAnchor).isActive = true
        }
    }
}
