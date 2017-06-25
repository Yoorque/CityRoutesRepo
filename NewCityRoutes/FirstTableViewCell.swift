//
//  FirstTableViewCell.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 3/17/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class FirstTableViewCell: UITableViewCell {
    
    @IBOutlet var cellImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var refNumber: UILabel!
    
    var model: Model? {
        didSet{
            cellImageView.image = model?.cellImage
            titleLabel.text = model?.titleLabel
            refNumber.text = model?.refNumber
            refNumber.textColor = model?.color
        }
    }
}

extension FirstTableViewCell {
    struct Model {
        let cellImage: UIImage
        let titleLabel: String
        let refNumber: String
        let color: UIColor
        
        init(route: Routes, transport: String) {
            self.cellImage = UIImage(named: transport)!
            if language == "latin" {
                self.titleLabel = route.routes[0].reltags.fromSrLatn + "-" + route.routes[0].reltags.toSrLatn
            } else {
                self.titleLabel = route.routes[0].reltags.from + "-" + route.routes[0].reltags.to
            }
            self.refNumber = route.ref
            self.color = UIColor.color(forTransport: transport)
        }
    }
}
