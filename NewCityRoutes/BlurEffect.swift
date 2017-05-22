//
//  BlurEffect.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 4/18/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class BlurEffect: UIView {
    
    func blurTheBackgound(view: UIView) {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }
    
}
