//
//  LoadingViewController.swift
//  NewCityRoutes
//
//  Created by Marko Tribl on 4/16/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            setupIndicator()
        }
    }
    
    let actIndicator = Bundle.main.loadNibNamed("CustomActivityIndicator", owner: self, options: nil)?.first as! CustomActivityIndicator
    
    var json = Json()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        json.readJson()
        instantiateViewController()
        actIndicator.actIndicator(isShowed: false)
    }
    
    private func setupIndicator() {
        actIndicator.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        actIndicator.layer.borderColor = UIColor.white.cgColor
        actIndicator.layer.cornerRadius = 10
        actIndicator.layer.borderWidth = 0.3
        imageView.addSubview(actIndicator)
        actIndicator.actIndicator(isShowed: true)
        actIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: actIndicator, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 90)
        
        let heightConstraint = NSLayoutConstraint(item: actIndicator, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 90)
        
        let xConstraint = NSLayoutConstraint(item: actIndicator, attribute: .centerX, relatedBy: .equal, toItem: self.imageView, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: actIndicator, attribute: .centerY, relatedBy: .equal, toItem: self.imageView, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([xConstraint, yConstraint, widthConstraint, heightConstraint])
    }
    
    private func instantiateViewController() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as! InitialViewController
        let navController = UINavigationController(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
    }
}
