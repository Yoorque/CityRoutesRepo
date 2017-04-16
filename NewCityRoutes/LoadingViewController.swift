//
//  LoadingViewController.swift
//  NewCityRoutes
//
//  Created by Marko Tribl on 4/16/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let actIndicator = Bundle.main.loadNibNamed("CustomActivityIndicator", owner: self, options: nil)?.first as! CustomActivityIndicator
    
    var json = Json()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupIndicator()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        json.readJson()
        instantiateViewController()
        actIndicator.actIndicator(isShowed: false)
    }
    
    private func setupIndicator() {
        let x = view.frame.size.width / 2 - actIndicator.frame.size.width / 2
        let y = view.frame.size.height / 2 - actIndicator.frame.size.height / 2
        actIndicator.frame.origin = CGPoint(x: x, y: y)
        actIndicator.layer.borderColor = UIColor.white.cgColor
        actIndicator.layer.cornerRadius = 10
        actIndicator.layer.borderWidth = 0.3
        imageView.addSubview(actIndicator)
        actIndicator.actIndicator(isShowed: true)
    }
    
    private func instantiateViewController() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as! InitialViewController
        self.present(controller, animated: true, completion: nil)
    }

}
